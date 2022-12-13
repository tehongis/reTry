VBCC=/usr/local/vbcc
PATH +=:$(VBCC)/bin
CC=vc +$(VBCC)/config/kick13
CFLAGS=-c99 -DNDEBUG -lamiga -lauto -I$(VBCC)/targets/m68k-kick13/include -I$(VBCC)/targets/m68k-kick13/include.h

HDD/demo.exe	:	main.c
	@echo "VBCC location: $(VBCC)"
	@echo "PATH: $(PATH)"
	$(CC) $(CFLAGS) main.c -o HDD/demo.exe

clean		:
	rm -f HDD/demo.exe

run		: HDD/demo.exe
			@fs-uae >/dev/null A500Dev.fs-uae
