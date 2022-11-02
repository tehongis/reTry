run		: main.prg
		x64sc -autostartprgmode 1 -silent -autostart main.prg

main.prg	: main.s	
		vasm6502_oldstyle -Fbin -cbm-prg -o main.prg main.s

