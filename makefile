# Compiler and flags
CXX      = g++
CXXFLAGS = -Wall -Wextra -std=c++17 -O2

# Fix: Added -lGLU to resolve the undefined reference to gluPerspective
LIBS     = -lGL -lGLU -lGLEW -lglfw

# Target executable name
TARGET   = opengl_game

# Source files
SRCS     = main.cpp

# Default target rule
all: $(TARGET)

# Rule to compile the executable
$(TARGET): $(SRCS)
	$(CXX) $(CXXFLAGS) $(SRCS) -o $(TARGET) $(LIBS)

# Rule to clean up compilation outputs
clean:
	rm -f $(TARGET)
