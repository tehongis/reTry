run: main.exe
	./main.exe

main.exe: main.cpp
	g++ -Wall -o main.exe -lm -lstdc++ -lSDL2 -lSDL2_image -lSDL2_mixer -lBox2D main.cpp

clean:
	rm main.exe
