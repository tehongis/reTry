@echo off
del /q *.o kura.run

vasmm68k_mot -Fhunkexe main.asm -o kura.run
if errorlevel 1 goto :error_main

echo.
echo === Great success!. ===
exit /b 0

:error_main
echo [VIRHE] Tiedoston main.asm kääntäminen epäonnistui!
goto :fail

:fail
echo.
echo === Fail. ===
exit /b 1
