
ifeq ($(OS),Windows_NT)
	SHELL=cmd.exe
	VASM=vasmm68k_mot_win32
	UAE="C:\Program Files\WinUAE\winuae64.exe"
	OPTS=  -Fhunkexe -kick1hunks -devpac -nosym -I includes -L listfile.txt
	OUTFILE = "demo.exe"


else
	OSFLAG += -D LINUX
	VASM=vasmm68k_mot
	UAE=fs-uae
	OPTS=  -Fhunkexe -kick1hunks -devpac -nosym -I includes -L listfile.txt
	OUTFILE = "demo.exe"
endif

run		:	demo.exe
		$(UAE) -f A500.uae

demo.exe	:	source.s
		$(VASM) $(OPTS) -o $(OUTFILE) source.s

