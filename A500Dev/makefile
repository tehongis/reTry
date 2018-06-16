
ifeq ($(OS),Windows_NT)
	SHELL=cmd.exe
	VASM=vasmm68k_mot_win32
	OUTFILE = "C:\Users\Public\Documents\Amiga Files\WinUAE\Harddrives\DevHDD\demo.exe"
else
	OSFLAG += -D LINUX
	VASM=vasmm68k_mot
	OUTFILE = "DevHDD\demo.exe"
endif

demo.exe	:	source.s
		$(VASM) -devpac -Fhunkexe -o $(OUTFILE) source.s

run		:	demo.exe
		fs-uae A500plus.fs-uae
