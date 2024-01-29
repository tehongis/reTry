

ifeq ($(OS),Windows_NT)
	RUNEMU = "C:\Program Files\WinUAE\winuae64.exe" -config=A500DevHDD.uae -s use_gui=no
	CLEAN = del
else
	RUNEMU = fs-uae A500plus.fs-uae
	CLEAN = rm 
endif

run		:	HDD/main.exe
	$(RUNEMU)

HDD/main.exe	:	main.o
		vlink \
			-bamigahunk \
			-t \
			-x \
			-Bstatic \
			-Cvbcc \
			-nostdlib \
			-mrel \
			m68k-amigaos/lib/startup.o \
			main.o \
			-Lm68k-amigaos/lib/ \
			-lvc \
			-o HDD/main.exe

main.o	:	main.asm
		vasmm68k_mot -Fhunk main.asm -o main.o -L listfile.txt
	
main.asm 	: main.c
		vbccm68k -c99 -Im68k-amigaos/include/ -Indk31/include_h/ main.c

clean	:
		$(CLEAN) main.s main.o HDD\main.exe

