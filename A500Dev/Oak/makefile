ifeq ($(OS),Windows_NT)

run		:	demo.exe
		move demo.exe "E:\A500PlusHDD\"
		"C:\Program Files\WinUAE\winuae64.exe" -f A500PlusDevHDD.uae -G

demo.exe	: main.s
		vasmm68k_mot_win32.exe -Fhunkexe -o demo.exe main.s

else

run		:	demo.exe
		mv demo.exe "/home/thongisto/Documents/FS-UAE/Hard Drives/A500Plus/"
		fs-uae --model=A500+ --hard_drive_0=A500Plus  --fast_memory=4096 --line_doubling=1 --scanlines=1 --fullscreen=0

demo.exe	: main.s
		vasmm68k_mot -Fhunkexe -o demo.exe main.s

endif

