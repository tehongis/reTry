#fs-uae --hard_drive_0=A500

run		:	demo.exe
		mv demo.exe "/home/thongisto/Documents/FS-UAE/Hard Drives/A500Plus/"
		fs-uae --model=A500+ --hard_drive_0=A500Plus  --fast_memory=4096 --line_doubling=1 --scanlines=1 --fullscreen=0
# --window_width=1400 --window_height=1080

demo.exe	: main.s
		vasmm68k_mot -Fhunkexe -o demo.exe main.s

