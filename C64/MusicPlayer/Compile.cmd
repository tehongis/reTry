@echo off

del player.prg
del main.lst

.\vasm6502_oldstyle.exe -L main.lst -cbm-prg -Fbin -o player.prg main.s
if %errorlevel% == 1 (
	pause
	exit /b %errorlevel%
)
REM "C:\Program Files\GTK3VICE-3.10-win64\bin\x64sc.exe" player.prg
"C:\Program Files\GTK3VICE-3.10-win64\bin\x64sc.exe" +confirmonexit -silent -autostartprgmode 1 -autostart player.prg
