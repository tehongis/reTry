
run		:	HDD/main.exe
	fs-uae A500plus.fs-uae


HDD/main.exe	:	main.c
	vc +config/aos68k -o ./HDD/main.exe main.c

clean	:
		rm -rf main.s main.o HDD/main.exe

