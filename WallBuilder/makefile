run		: main.prg
	x64 main.prg
main.prg	: main.asm
	vasm6502_oldstyle -Fbin -cbm-prg -o main.prg main.asm 

clean		:
	rm main.prg
