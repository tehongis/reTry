
run		:	HDD/main.exe
	fs-uae A500plus.fs-uae

HDD/main.exe	:	main.o
		vlink \
			-bamigahunk \
			-t \
			-x \
			-Bstatic \
			-Cvbcc \
			-nostdlib \
			-mrel \
			/home/thongisto/Srcs/AmigaIncludes/vbcc_target_m68k-amigaos/targets/m68k-amigaos/lib/startup.o \
			main.o \
			-L/home/thongisto/Srcs/AmigaIncludes/vbcc_target_m68k-amigaos/targets/m68k-amigaos/lib/ \
			-lvc \
			-o HDD/main.exe

#	alleyrainnight-640x640x5-colors-after.raw

main.o	:	main.asm
		vasmm68k_mot -Fhunk main.asm -o main.o
	
main.asm 	: main.c
		vbccm68k -c99 -I/home/thongisto/Srcs/AmigaIncludes/ndk_3.1/includes\&libs/include_h/ -I/home/thongisto/Srcs/AmigaIncludes/vbcc_target_m68k-amigaos/targets/m68k-amigaos/ main.c

clean	:
		rm -rf main.s main.o HDD/main.exe
