run		: main.prg
		x64 +confirmonexit -autostartprgmode 1 main.prg

main.prg	: main.s
	vasm6502_oldstyle -Fbin -cbm-prg -o main.prg main.s

clean		:
		rm -rf main.prg
