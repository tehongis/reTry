@echo off
"C:\Program Files (x86)\Vasm\vasm6502_oldstyle_win32.exe" -Fbin -cbm-prg -o petmain.prg petmain.s

if %ErrorLevel% == 0 (
    "C:\Program Files (x86)\WinVICE3.2\xpet.exe" -silent -autostartprgmode 1 -autostart petmain.prg
)
