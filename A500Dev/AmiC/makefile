
run		:	HDD/main.exe
	fs-uae A500plus.fs-uae

ifeq ($(OS),Windows_NT)
HDD/main.exe	:	main.c
	vc +config/aos68kwin -o HDD/main.exe main.c
else
HDD/main.exe	:	main.c
	vc +config/aos68k -o HDD/main.exe main.c
endif

clean	:
		rm -rf main.s main.o HDD/main.exe

