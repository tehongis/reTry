run		: demo.exe
		"C:\Program Files\WinUAE\winuae64.exe" -G -f "A500Dev.uae"
	
CC=vc +kick13
#CFLAGS=-o demo.exe -c99 -DNDEBUG -lamiga -lauto
CFLAGS=-o demo.exe -lauto
demo.exe	:	main.c
		$(CC) main.c $(FLAGS) 
