@echo off

del demo.prg
"C:\Program Files\Vasm\vasm6502_oldstyle_win32.exe" -o demo.prg -Fbin -cbm-prg main.s
if %errorlevel%==0 goto :runemu
goto :endofscript

:runemu
"C:\Program Files\GTK3VICE-3.7-win64\bin\x64sc.exe" -silent -autostart demo.prg -autostartprgmode 1

:endofscript
