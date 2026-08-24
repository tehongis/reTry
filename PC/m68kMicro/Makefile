# =============================================================================
# Rocket68 Toolchain Makefile (NMAKE / Windows Version) - FONT FIX
# =============================================================================

# --- Työkalut ja Kääntäjät ---
CC       = cl
ASM68K   = vasmm68k_mot
PYTHON   = python

# --- Hakemistorakenteet ---
BIN_DIR     = bin
OS_BIN_DIR  = os_bin
INC_DIR     = include
LIB_DIR     = lib
SRC_DIR     = .

# --- Kääntäjän liput (C-emulaattoria varten) ---
CFLAGS   = /nologo /W4 /std:c11 /I$(INC_DIR) /D_CRT_SECURE_NO_WARNINGS /D_WIN32 /Zi /Od /MDd /D_DEBUG

# --- Kohdetiedostot ---
EMU_EXE  = $(BIN_DIR)\rocket68_emu.exe
BIOS_BIN = $(OS_BIN_DIR)\bios.bin
LOADER   = $(OS_BIN_DIR)\loader.bin
MONITOR  = $(OS_BIN_DIR)\monitor.bin
FONT_BIN = os_bin\font.bin
HDD_IMG  = hdd.img

# KORJAUS: Määritellään fontille virallinen kohdepolku, jossa emulaattori sitä odottaa
FONT_ROM = os_bin\FONT.ROM

# =============================================================================
# PÄÄKOHTEET (Targets)
# =============================================================================

# KORJAUS: Lisätty $(FONT_ROM) all-kohteen listaan, jotta se rakennetaan aina!
all: setup $(EMU_EXE) $(BIOS_BIN) $(LOADER) $(MONITOR) $(FONT_BIN) $(HDD_IMG)

# Luodaan kansiot jos niitä ei ole olemassa
setup:
	@if not exist $(BIN_DIR) mkdir $(BIN_DIR)
	@if not exist $(OS_BIN_DIR) mkdir $(OS_BIN_DIR)

$(EMU_EXE): main.c
	$(CC) $(CFLAGS) main.c $(LIB_DIR)\librocket68.lib /Fe$@ /link user32.lib kernel32.lib gdi32.lib /DEBUG /MANIFEST

$(BIOS_BIN): bios.asm
	$(ASM68K) -Fbin -o $@ bios.asm

$(LOADER): loader.asm
	$(ASM68K) -Fbin -o $@ loader.asm

$(MONITOR): monitor.asm
	$(ASM68K) -Fbin -o $@ monitor.asm

$(FONT_BIN): font.asm
	@echo [MAKE] Käännetään font.bin tiedostosta font.asm...
	$(ASM68K) -Fbin -o $@ font.asm

# KORJAUS: Lisätty virallinen sääntö FONT.ROM-tiedostolle.
# Jos se puuttuu os_bin-kansiosta, etsitään se projektin juuresta tai ROMs-kansiosta ja kopioidaan talteen!
$(FONT_ROM):
	@echo [MAKE] Varmistetaan FONT.ROM-tiedoston olemassaolo...
	@if exist FONT.ROM ( copy /Y FONT.ROM $(OS_BIN_DIR)\FONT.ROM >nul ) \
	else if exist ROMs\FONT.ROM ( copy /Y ROMs\FONT.ROM $(OS_BIN_DIR)\FONT.ROM >nul ) \
	else ( echo [VIRHE] Alkuperäistä FONT.ROM tiedostoa ei loytynyt projektista! && exit 1 )

$(HDD_IMG): $(LOADER) $(MONITOR) build_indexed_hd.py
	@echo [MAKE] Kutsutaan build_indexed_hd.py -skriptia levyn luontiin...
	$(PYTHON) build_indexed_hd.py

run: all
	@echo [MAKE] Kaynnistetaan Rocket68-emulaattori...
	$(EMU_EXE)

# =============================================================================
# SIIVOUKSET (Clean)
# =============================================================================

clean:
	@echo [MAKE] Siivotaan väliaikaistiedostot ja vanha levykuva...
	@if exist main.obj del main.obj
	@if exist vc140.pdb del vc140.pdb
	@if exist $(BIN_DIR) rmdir /s /q $(BIN_DIR)
	@if exist $(OS_BIN_DIR) rmdir /s /q $(OS_BIN_DIR)
	@if exist $(HDD_IMG) del $(HDD_IMG)
	@echo [MAKE] Siivous valmis.
