####################################################################################################
## Microsoft NMAKE Makefile - Täysi Automatisoitu M68k Alusta (Turvallinen Clean & Allekirjoitus)
####################################################################################################

CC = cl
ASM = vasmm68k_mot
CFLAGS = /nologo /W4 /std:c11 /Iinclude /D_CRT_SECURE_NO_WARNINGS /D_WIN32
ASMFLAGS = -Fbin -o

# Koodin allekirjoituksen asetukset (Smart App Controlia varten)
SIGNTOOL = signtool
SIGN_FLAGS = sign /a /v /fd SHA256 /s My /n "MyLocalAppSigning"

!IF "$(BUILD_TYPE)" == "release"
CFLAGS = $(CFLAGS) /O2 /DNDEBUG
!ELSE
CFLAGS = $(CFLAGS) /Zi /Od /MDd /D_DEBUG
!ENDIF

# Hakemistot ja tiedostopolut
BIN_DIR = bin
ROM_DIR = ROMs
STATIC_LIB = lib\librocket68.lib
EMU_BINARY = bin\rocket68_emu.exe
BIOS_ROM = ROMs\BIOS.ROM

all: $(BIOS_ROM) $(EMU_BINARY)

# 1. SÄÄNTÖ: Käännetään BIOS.ASM automaattisesti ROMs/ kansioon
$(BIOS_ROM): BIOS.ASM
	@if not exist $(ROM_DIR) mkdir $(ROM_DIR)
	$(ASM) $(ASMFLAGS) $@ BIOS.ASM

# 2. SÄÄNTÖ: Käännetään main.c, linkitetään emulaattoriksi bin/ kansioon ja ALLEKIRJOITETAAN
$(EMU_BINARY): main.c $(STATIC_LIB)
	@if not exist $(BIN_DIR) mkdir $(BIN_DIR)
# Lisätty /MANIFEST, jotta Windows tunnistaa binäärin paremmin
	$(CC) $(CFLAGS) main.c $(STATIC_LIB) /Fe$@ /link user32.lib kernel32.lib gdi32.lib /DEBUG /MANIFEST
# Miinusmerkki (-) komennon edessä estää NMAKEa kaatumasta, jos Windows lukitsee tiedoston hetkellisesti
	-$(SIGNTOOL) $(SIGN_FLAGS) $@

run: $(BIOS_ROM) $(EMU_BINARY)
	$(EMU_BINARY)

# KORJATTU: clean poistaa vain generoidut tiedostot, ei koske fonttitiedostoon!
clean:
	@if exist $(BIN_DIR) rmdir /s /q $(BIN_DIR)
	@if exist $(BIOS_ROM) del /f /q $(BIOS_ROM)
	@if exist *.obj del *.obj
	@if exist *.pdb del *.pdb
	@if exist *.ilk del *.ilk
