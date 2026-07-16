# Kääntäjä ja perusliput
CXX      = g++
CXXFLAGS = -Wall -Wextra -std=c++17 -O2

# Muuta tämä arvoon 1, jos haluat käyttää SDL2:ta GLFW:n sijaan!
USE_SDL2 = 0

ifeq ($(USE_SDL2), 1)
    # SDL2-asetukset: haetaan tarvittavat liput järjestelmästä automaattisesti
    CXXFLAGS += -DUSE_SDL2 $(shell sdl2-config --cflags)
    LIBS      = $(shell sdl2-config --libs) -lGL -lGLU -lGLEW -lopenal -lalut
else
    # Alkuperäiset GLFW-asetukset
    LIBS      = -lGL -lGLU -lGLEW -lglfw -lopenal -lalut
endif

TARGET   = opengl_game
SRCS     = main.cpp

all: $(TARGET)

$(TARGET): $(SRCS)
	$(CXX) $(CXXFLAGS) $(SRCS) -o $(TARGET) $(LIBS)

clean:
	rm -f $(TARGET)

run: $(TARGET)
	./$(TARGET)	
