@echo off
"C:\Program Files (x86)\Vasm\vasm6502_oldstyle_win32.exe" -Fbin -cbm-prg -o main.prg main.s

if %ErrorLevel% == 0 (
    #"C:\Program Files\GTK3VICE-3.4\x64sc.exe" -silent -autostartprgmode 1 -autostart main.prg
    "C:\Program Files (x86)\WinVICE3.2\x64sc.exe" -silent -autostartprgmode 1 -autostart main.prg
)
