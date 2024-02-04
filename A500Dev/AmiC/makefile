

ifeq ($(OS),Windows_NT)
	RUNEMU = "C:\Program Files\WinUAE\winuae64.exe" -config=A500DevHDD.uae -s use_gui=no
	CLEAN = del
else
	RUNEMU = fs-uae A500plus.fs-uae
	CLEAN = rm 
endif

run		:	HDD/main.exe
	$(RUNEMU)

image.bin		: image.s
		vasmm68k_mot.exe -linedebug -Fhunk -o image.bin .\image.s

HDD/main.exe	:	main.c
		vc +aos68km -o HDD/main.exe main.c

clean	:
		$(CLEAN) main.s main.o HDD\main.exe

