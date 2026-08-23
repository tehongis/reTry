@echo off
del /q *.o kura.run

vasmm68k_mot -Fhunk init.asm -o init.o
if errorlevel 1 goto :error_init

vasmm68k_mot -Fhunk ptplayer.asm -o ptplayer.o
if errorlevel 1 goto :error_ptplayer

vasmm68k_mot -Fhunk irq.asm -o irq.o
if errorlevel 1 goto :error_irq

vasmm68k_mot -Fhunk blitter.asm -o blitter.o
if errorlevel 1 goto :error_blitter

vasmm68k_mot -Fhunk data.asm -o data.o
if errorlevel 1 goto :error_data

echo.
echo === KAIKKI TIEDOSTOT KAANNYTTY ONNISTUNEESTI. LINKITETAAN... ===
vlink -bamigahunk init.o irq.o blitter.o data.o ptplayer.o -o kura.run
if errorlevel 1 goto :error_link

echo.
echo === VALMIS! kura.run luotu onnistuneesti. ===
exit /b 0

:error_init
echo [VIRHE] Tiedoston init.asm kääntäminen epäonnistui!
goto :fail

:error_ptplayer
echo [VIRHE] Tiedoston ptplayer.asm kääntäminen epäonnistui!
goto :fail

:error_irq
echo [VIRHE] Tiedoston irq.asm kääntäminen epäonnistui!
goto :fail

:error_blitter
echo [VIRHE] Tiedoston blitter.asm kääntäminen epäonnistui!
goto :fail

:error_data
echo [VIRHE] Tiedoston data.asm kääntäminen epäonnistui!
goto :fail

:error_link
echo [VIRHE] Linkittäminen vlinkillä epäonnistui!
goto :fail

:fail
echo.
echo === KAANTO TAI LINKITYS EPAONNISTUI. PROSESSI PYSAYTETTY. ===
exit /b 1
