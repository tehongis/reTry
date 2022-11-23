
run			:	demo.prg
			"C:\Program Files\VICE-3.6.1\bin\x64sc.exe" -autostartprgmode 1 demo.prg

demo.prg	:	main.s
			vasm6502_oldstyle_win32.exe -Fbin -cbm-prg -o demo.prg main.s
		
clean		:	demo.prg
			del demo.prg