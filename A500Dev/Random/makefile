run		:	random.exe
		fs-uae	
random.exe	:	random.asm
		vasmm68k_mot -Fhunkexe -o random.exe random.asm 
		mv random.exe "/home/thongisto/Asiakirjat/FS-UAE/Hard Drives/DevHDD/main.exe" 
clean		: 
		rm "/home/thongisto/Asiakirjat/FS-UAE/Hard Drives/DevHDD/main.exe"
		rm random.exe
