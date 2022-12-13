
@echo off

del main.prg
"C:\Program Files\Vasm\vasm6502_oldstyle_win32.exe" -o main.prg -Fbin -cbm-prg main.asm
if %errorlevel%==0 goto :runemu
goto :endofscript

:runemu
"C:\Program Files\GTK3VICE\x64sc.exe" -autostart main.prg -autostartprgmode 1

:endofscript
