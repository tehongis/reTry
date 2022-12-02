run	:	2022-day02.prg
	x64sc.exe -autostartprgmode 1 2022-day02.prg

2022-day02.prg	:	2022-day02-code.asm
	vasm6502_oldstyle_win32.exe -Fbin -cbm-prg -o 2022-day02.prg 2022-day02-code.asm

clean	:
	del 2022-day02.prg
