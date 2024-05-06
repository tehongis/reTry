run		:	demo.exe
		move demo.exe "E:\A500PlusHDD\"
		"C:\Program Files\WinUAE\winuae64.exe" -f A500PlusDevHDD.uae -G

demo.exe	:	main.c protracker_replay.o image.o
			vc +aos68k protracker_replay.o image.o main.c -lamiga -o demo.exe
#			vc -vv +aos68k data.o main.c

protracker_replay.o	:	protracker_replay.s
			vasmm68k_mot.exe -x -Lall -Fvobj -o protracker_replay.o protracker_replay.s

image.o		: image.s
			vasmm68k_mot.exe -x -Lall -Fvobj -o image.o image.s

clean		:
		del image.o protracker_replay.o demo.exe

