# =============================================================================
# Rocket68 Toolchain Makefile (NMAKE / Windows Version) - RIISUTTU SUOJAUSKIERTO
# =============================================================================

# --- Työkalut ja Kääntäjät ---
CC       = cl
ASM68K   = vasmm68k_mot # VAIHDA TÄHÄN TARKKA M68K-ASSEMBLERIN KOMENTO
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
HDD_IMG  = hdd.img

# =============================================================================
# PÄÄKOHTEET (Targets)
# =============================================================================

all: setup $(EMU_EXE) $(BIOS_BIN) $(LOADER) $(MONITOR) $(HDD_IMG)

# Luodaan molemmat kansiot jos niitä ei ole olemassa
setup:
	@if not exist $(BIN_DIR) mkdir $(BIN_DIR)
	@if not exist $(OS_BIN_DIR) mkdir $(OS_BIN_DIR)

# 1. Käännetään C-emulaattori puhtaana ilman Windows-resursseja (.res)
$(EMU_EXE): main.c
	$(CC) $(CFLAGS) main.c $(LIB_DIR)\librocket68.lib /Fe$@ /link user32.lib kernel32.lib gdi32.lib /DEBUG /MANIFEST

$(BIOS_BIN): bios.asm
	$(ASM68K) -Fbin -o $@ bios.asm

$(LOADER): loader.asm
	$(ASM68K) -Fbin -o $@ loader.asm

$(MONITOR): monitor.asm
	$(ASM68K) -Fbin -o $@ monitor.asm

$(HDD_IMG): $(LOADER) $(MONITOR) build_indexed_hd.py
	@echo [MAKE] Rakennetaan Custom LBA-tiedostojärjestelmä...
	$(PYTHON) build_indexed_hd.py

# Käynnistää emulaattorin automaattisesti kääntämisen jälkeen
run: all
	@echo [MAKE] Kaynnistetaan Rocket68-emulaattori...
	$(EMU_EXE)

# =============================================================================
# SIIVOUKSET (Clean)
# =============================================================================

clean:
	@echo [MAKE] Siivotaan väliaikaistiedostot...
	@if exist main.obj del main.obj
	@if exist vc140.pdb del vc140.pdb
	@if exist $(BIN_DIR) rmdir /s /q $(BIN_DIR)
	@if exist $(OS_BIN_DIR) rmdir /s /q $(OS_BIN_DIR)
	@if exist $(HDD_IMG) del $(HDD_IMG)
	@echo [MAKE] Siivous valmis.
