VBCC=/usr/local/vbcc
PATH +=:$(VBCC)/bin
CC=vc +m68k-kick13
CFLAGS=-c99 -DNDEBUG -lamiga -lauto
#CFLAGS=-c99 -Ireqtools -DNDEBUG -lamiga -lauto


HDD/demo.exe	:	main.c
	@echo "VBCC location: $(VBCC)"
	@echo "PATH: $(PATH)"
	vc +$(VBCC)/config/kick13m -I$(VBCC)/targets/m68k-kick13/include -I$(VBCC)/targets/m68k-kick13/include.h main.c -o HDD/demo.exe
	# -nostdlib
#

# -sc -sd -O2 -DAMIGA -DCPU=68000 $(VBCC)/targets/m68k-kick13/lib/minstart.o

clean		:
	rm -f HDD/demo.exe

run		: HDD/demo.exe
			@fs-uae >/dev/null A500Dev.fs-uae
