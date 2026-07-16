# Kääntäjä ja liput
CXX      := g++
CXXFLAGS := -Wall -Wextra -std=c++17 -O2

# Järjestelmäkirjastot
LIBS     := -lSDL2 -lGLEW -lGL -lm

# Kohteet (Etsii automaattisesti kaikki .cpp tiedostot nykyisestä kansiosta)
TARGET   := mars_terrain
SRCS     := $(wildcard *.cpp)
OBJS     := $(SRCS:.cpp=.o)

# Oletuskomento
all: $(TARGET)

# Linkitysvaihe yhdistää kaikki objektitiedostot binääriksi
$(TARGET): $(OBJS)
	$(CXX) $(CXXFLAGS) -o $@ $^ $(LIBS)

# Käännösvaihe jokaiselle .cpp tiedostolle erikseen
%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

# Siivouskomento uudelleenkäännöstä varten
clean:
	rm -f $(OBJS) $(TARGET)

.PHONY: all clean
