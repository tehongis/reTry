run		:	random.exe
		fs-uae A500plus.fs-uae

random.exe	:	random.asm
		vasmm68k_mot -Fhunkexe -o ./HDD/random.exe random.asm 
clean		: 
		rm "./HDD/random.exe"
