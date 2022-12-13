run		: main.prg
		x64sc -autostartprgmode 1 -silent -autostart main.prg

main.prg	: main.s	
		vasm6502_oldstyle_win32.exe -Fbin -cbm-prg -o main.prg main.s

