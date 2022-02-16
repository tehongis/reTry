@echo off
"C:\Program Files\vasm\vasm6502_oldstyle_win32.exe" -Fbin -cbm-prg -o main.prg main.s

if %ErrorLevel% == 0 (
    "C:\Program Files\GTK3VICE-3.5-win64\bin\x64sc.exe" -silent -autostartprgmode 1 -autostart main.prg
)
