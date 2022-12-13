
./HDD/demo.exe	:	Srcs/source.s
		vasmm68k_mot -I includes -Fhunkexe -kick1hunks -m68000 -o ./HDD/demo.exe Srcs/source.s
		
clean		: 
		rm ./HDD/demo.exe

run		:	./HDD/demo.exe
		fs-uae A500plus.fs-uae
	