import os
import sys
import json
import re
import subprocess
import requests
import time
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

# --- CONFIGURATION ---
OLLAMA_URL = "http://localhost:11434/api/chat"
MODEL_NAME = "granite4.1:8b"
WORKSPACE_DIR = os.getcwd()

PROMPT_FILE = "agent_prompt.txt"
HISTORY_FILE = "agent_history.json"
MAX_ITERATIONS = 5  # Sallii 5 korjausyritystä kääntäjän virheille

# --- SYSTEM PROMPT ---
SYSTEM_PROMPT = """You are an expert M68k Development and Windows Emulator Engineering Assistant.
You are running as a background file-watcher agent. You can see and modify files directly.

Target Environments:
1. Motorola 68000 Assembly: Uses 'vasm' (mot syntax). Focus on strict data sizes (.b, .w, .l), proper register usage (d0-d7, a0-a7), and cycle optimization.
2. Windows Emulator Code: Written in Visual C++ (MSVC). Focus on fast instruction decoding, precise memory-mapped I/O simulation, and Win32/SDL performance loops.

Tool Formats (Output exactly like this, nothing else when calling a tool):
[TOOL:LIST_FILES]
[TOOL:READ_FILE:filename.ext]
[TOOL:READ_BIN_FILE:filename.bin]
[TOOL:WRITE_FILE:filename.ext]
file contents here...
[TOOL:END_WRITE]
[TOOL:BUILD_VASM:source.asm:output.bin]
[TOOL:BUILD_MSVC:source.cpp:output.exe]

CRITICAL RULES:
1. NEVER ask the user to provide or paste the contents of a file if it already exists in the workspace. Use [TOOL:READ_FILE:filename.ext] to read it yourself first.
2. If you do not know what files are in the workspace, ALWAYS use [TOOL:LIST_FILES] first.
3. Always wait for tool results before finalizing your reply if a tool is required.

Self-Correction Rule:
If a BUILD tool returns a [Tool Error] with compiler/assembler errors, analyze the error log, modify the source file using WRITE_FILE, and compile again. You have multiple iterations to make it build successfully before providing your final response."""

def load_history():
    """Lataa aiemman keskusteluhistorian ja varmistaa system promptin olemassaolon."""
    path = os.path.join(WORKSPACE_DIR, HISTORY_FILE)
    if os.path.exists(path):
        try:
            with open(path, 'r', encoding='utf-8') as f:
                return json.load(f)
        except Exception:
            pass
    return [{"role": "system", "content": SYSTEM_PROMPT}]

def save_history(messages):
    """Tallentaa keskusteluhistorian levylle."""
    path = os.path.join(WORKSPACE_DIR, HISTORY_FILE)
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(messages, f, indent=4, ensure_ascii=False)

def send_to_ollama(messages):
    """Lähettää viestihistorian paikalliselle Ollama-rajapinnalle."""
    payload = {"model": MODEL_NAME, "messages": messages, "stream": False}
    try:
        response = requests.post(OLLAMA_URL, json=payload, timeout=60)
        response.raise_for_status()
        return response.json()['message']['content']
    except requests.exceptions.RequestException as e:
        print(f"\n[Ollama Error]: {e}")
        return None
def read_binary_as_hex(filepath, max_bytes=4096):
    """Lukee binääritiedoston (.bin) ja muuntaa sen siistiksi heksadumpiksi."""
    if not os.path.exists(filepath):
        return f"[Tool Error]: Binary file '{os.path.basename(filepath)}' not found."
    
    try:
        with open(filepath, 'rb') as f:
            data = f.read(max_bytes)
        
        if not data:
            return f"[Tool Result - {os.path.basename(filepath)}]: File is empty."
        
        lines = []
        lines.append(f"[Tool Result - Hex Dump of {os.path.basename(filepath)} ({len(data)} bytes shown)]:")
        
        for i in range(0, len(data), 16):
            chunk = data[i:i+16]
            hex_part = " ".join(f"{b:02X}" for b in chunk)
            if len(chunk) < 16:
                hex_part += " " * (16 - len(chunk)) * 3
            
            ascii_part = "".join(chr(b) if 32 <= b <= 126 else "." for b in chunk)
            lines.append(f"{i:08X}: {hex_part}  |{ascii_part}|")
            
        return "\n".join(lines)
    except Exception as e:
        return f"[Tool Error]: Failed to read binary file. {str(e)}"

def execute_tools(content):
    """Parsii ja suorittaa tekstistä löytyvät työkalukutsut regexin avulla."""
    def safe_path(filename):
        return os.path.join(WORKSPACE_DIR, os.path.basename(filename.strip()))

    outputs = []

    # 1. LIST_FILES
    if "[TOOL:LIST_FILES]" in content:
        files = [f for f in os.listdir(WORKSPACE_DIR) if f not in [HISTORY_FILE, PROMPT_FILE]]
        outputs.append(f"[Tool Result]: Files in workspace: {', '.join(files) if files else 'Empty.'}")

    # 2. READ_FILE (Tekstitiedostot)
    read_matches = re.findall(r"\[TOOL:READ_FILE:\s*(.*?)\s*\]", content)
    for filename in read_matches:
        try:
            with open(safe_path(filename), 'r', encoding='utf-8') as f:
                outputs.append(f"[Tool Result - Contents of {filename}]:\n{f.read()}")
        except Exception as e:
            outputs.append(f"[Tool Error]: Could not read file '{filename}'. {str(e)}")

    # 3. READ_BIN_FILE (Motorola binääritiedostot heksana)
    read_bin_matches = re.findall(r"\[TOOL:READ_BIN_FILE:\s*(.*?)\s*\]", content)
    for filename in read_bin_matches:
        outputs.append(read_binary_as_hex(safe_path(filename)))

    # 4. WRITE_FILE
    write_matches = re.findall(r"\[TOOL:WRITE_FILE:\s*(.*?)\s*\](.*?)\[TOOL:END_WRITE\]", content, re.DOTALL)
    for filename, file_data in write_matches:
        try:
            with open(safe_path(filename), 'w', encoding='utf-8') as f:
                f.write(file_data.strip())
            outputs.append(f"[Tool Result]: File '{filename}' successfully written.")
        except Exception as e:
            outputs.append(f"[Tool Error]: Could not write file '{filename}'. {str(e)}")

    # 5. BUILD_VASM (M68K Kääntäminen ja automaattinen virhelokitus)
    vasm_matches = re.findall(r"\[TOOL:BUILD_VASM:\s*(.*?)\s*:\s*(.*?)\s*\]", content)
    for src, out in vasm_matches:
        try:
            cmd = f"vasmm68k_mot -Fbin -nocase -o \"{safe_path(out)}\" \"{safe_path(src)}\""
            res = subprocess.run(cmd, capture_output=True, text=True, shell=True)
            if res.returncode == 0:
                outputs.append(f"[Tool Result]: vasm build success for {src}!\nSTDOUT:\n{res.stdout}")
            else:
                outputs.append(f"[Tool Error]: vasm build failed for {src}!\n--- COMPILER ERROR LOG ---\nSTDOUT:\n{res.stdout}\nSTDERR:\n{res.stderr}\n--- END LOG ---")
        except Exception as e:
            outputs.append(f"[Tool Error]: Execution failed for vasm build ({src}). {str(e)}")

    # 6. BUILD_MSVC (C++ Kääntäminen ja automaattinen virhelokitus)
    msvc_matches = re.findall(r"\[TOOL:BUILD_MSVC:\s*(.*?)\s*:\s*(.*?)\s*\]", content)
    for src, out in msvc_matches:
        try:
            cmd = f"cl.exe /EHsc \"{safe_path(src)}\" /Fe\"{safe_path(out)}\""
            res = subprocess.run(cmd, capture_output=True, text=True, shell=True)
            if res.returncode == 0:
                outputs.append(f"[Tool Result]: MSVC build success for {src}!\nSTDOUT:\n{res.stdout}")
            else:
                outputs.append(f"[Tool Error]: MSVC build failed for {src}!\n--- COMPILER ERROR LOG ---\nSTDOUT:\n{res.stdout}\nSTDERR:\n{res.stderr}\n--- END LOG ---")
        except Exception as e:
            outputs.append(f"[Tool Error]: Execution failed for MSVC build ({src}). {str(e)}")

    if not outputs:
        return None
    
    return "\n\n".join(outputs)
def process_agent_loop(user_request):
    """Pyörittää ReAct-silmukkaa. Jos työkalu palauttaa virheen, malli yrittää korjata koodin lennosta."""
    messages = load_history()
    messages.append({"role": "user", "content": user_request})
    
    print(f"\n[Agent]: Processing updated request...")
    
    iterations = 0
    while iterations < MAX_ITERATIONS:
        print(f"Thinking (Step {iterations+1}/{MAX_ITERATIONS})...", end="\r")
        ai_response = send_to_ollama(messages)
        if not ai_response:
            print("\n[Agent Error]: No response from Ollama.")
            break
        
        messages.append({"role": "assistant", "content": ai_response})
        
        # Suoritetaan työkalut (sisältää kääntämisen ja binääriluvun)
        tool_output = execute_tools(ai_response)
        
        if tool_output:
            print(f"\n[Agent Actions]: Executing tools & Analyzing results...")
            
            # Havaitaan kääntäjän virheet lokista ja ilmoitetaan siitä konsoliin
            if "COMPILER ERROR LOG" in tool_output:
                print("[Self-Correction]: Compiler error detected! Feeding logs back to Agent for auto-fix...")
            
            print(tool_output)
            messages.append({"role": "user", "content": tool_output})
            iterations += 1
            time.sleep(0.1)
        else:
            print(f"\n[Agent Final Response]:\n{ai_response}")
            break
    else:
        print(f"\n[Agent Warning]: Reached maximum iteration limit ({MAX_ITERATIONS}). Auto-fix loop stopped.")
            
    save_history(messages)

def main():
    print("====================================================")
    print(" VS Code Live Workspace Agent Terminal Chat         ")
    print(f" Workspace: {WORKSPACE_DIR} | Model: {MODEL_NAME}")
    print("====================================================")
    print("Agentti on valmis. Voit antaa ohjeita suoraan alle.")
    print("Kirjoita 'exit' tai 'quit' sulkeaksesi agentin.\n")

    try:
        while True:
            user_input = input("\n[Sinä]: ").strip()
            if not user_input:
                continue
            if user_input.lower() in ['exit', 'quit']:
                print("Lopetetaan...")
                break
                
            process_agent_loop(user_input)
    except KeyboardInterrupt:
        print("\nKeskeytetty näppäimistöltä. Lopetetaan...")

if __name__ == "__main__":
    main()

