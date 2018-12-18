ifeq ($(OS),Windows_NT)
run		:	main.prg
		"C:\Program Files\WinVICE-3.1-x64/x64" -autostartprgmode 1 Release/main.prg
main.prg	:	main.s
		"C:\Program Files (x86)\Vasm\vasm6502_oldstyle_win32.exe" -Fbin -cbm-prg -o Release/main.prg main.s
else
	run		:	main.prg
			x64 -autostartprgmode 1 Release/main.prg
	main.prg	:	main.s
			vasm6502_oldstyle -Fbin -cbm-prg -o Release/main.prg main.s
endif
