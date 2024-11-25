
rom.bin	:	main.s
	vasm6502_oldstyle.exe -Fbin -cbm-prg -o rom.bin main.s

run		: rom.bin
	C:\Program Files\GTK3VICE-3.7-win64\bin\x64sc -autostartprgmode 1 rom.bin
	
