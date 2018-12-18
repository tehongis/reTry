@echo off
set VASM=vasm6502_oldstyle_win32.exe
set EMULATOR="C:\Program Files\WinVICE-3.1-x64\x64"
%VASM% -Fbin -cbm-prg -o Release/main.prg main.s
if %errorlevel% == 1 (
	pause
	exit /b %errorlevel%
)
%EMULATOR% Release/main.prg
