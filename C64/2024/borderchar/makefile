
ifeq ($(OS),Windows_NT)
	CC=vasm6502_oldstyle_win32.exe
	EMU=x64sc.exe
else
	CC=vasm6502_oldstyle
	EMU=x64
endif

CODENAME	:= borderchar

run				:	$(CODENAME).prg
				$(EMU) -autostartprgmode 1 $(CODENAME).prg


$(CODENAME).prg : $(CODENAME).s 
				$(CC) -Fbin -cbm-prg -o $(CODENAME).prg $(CODENAME).s


