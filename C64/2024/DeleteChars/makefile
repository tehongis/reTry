
ifeq ($(OS),Windows_NT)
	CC=vasm6502_oldstyle_win32.exe
	EMU=x64sc.exe
else
	CC=vasm6502_oldstyle
	EMU=x64
endif

run			: demo.prg
			$(EMU) -autostartprgmode 1 demo.prg

demo.prg	:	main.s
			$(CC) -Fbin -cbm-prg -o demo.prg main.s

