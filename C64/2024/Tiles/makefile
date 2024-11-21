
ifeq ($(OS),Windows_NT)
	CC=vasm6502_oldstyle_win32.exe
	EMU=x64sc.exe
else
	CC=vasm6502_oldstyle
	EMU=x64
endif

run			: Tiles.prg
			$(EMU) -autostartprgmode 1 Tiles.prg

Tiles.prg	:	main.s
			$(CC) -Fbin -cbm-prg -o Tiles.prg main.s

