run				: main.tap
					"C:\Program Files (x86)\Speccy\Speccy.exe" main.tap

main.tap	: main.o
					"C:\Program Files (x86)\Speccy\bin2tap.exe" -b -a 32768 -o main.tap main.bin

main.o	: main.asm
					vasmz80_oldstyle_win32.exe -o main.bin -Fbin -z80asm main.asm
