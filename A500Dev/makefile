
ifeq ($(OS),Windows_NT)
	SHELL=cmd.exe
	VASM=vasmm68k_mot_win32
	#OPTS=  -Fhunkexe -kick1hunks -devpac -nosym
	OPTS=  -Fhunkexe -devpac -nosym -L listfile.txt
	OUTFILE = "C:\Users\Public\Documents\Amiga Files\WinUAE\Harddrives\DevHDD\demo.exe"
else
	OSFLAG += -D LINUX
	VASM=vasmm68k_mot
	OPTS=  -Fhunkexe -devpac -nosym -L listfile.txt
	OUTFILE = "DevHDD\demo.exe"
endif

demo.exe	:	source.s
		$(VASM) $(OPTS) -o $(OUTFILE) source.s

run		:	demo.exe
		fs-uae A500plus.fs-uae
