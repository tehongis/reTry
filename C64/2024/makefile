
ifeq ($(OS),Windows_NT)
	CC=vasm6502_oldstyle_win32.exe
	EMU=x64sc.exe
else
	CC=vasm6502_oldstyle
	EMU=x64
endif

run			: 2024.prg
			$(EMU) -autostartprgmode 1 2024.prg

2024.prg	:	main.s
			$(CC) -Fbin -cbm-prg -o 2024.prg main.s

