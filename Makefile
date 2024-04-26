# Makefile for building the scanner

# Set the compiler and compiler flags
CXX = g++
CXXFLAGS = -Wall

# Define the source files and the output file
SRC = scanner.l
OBJ = lex.yy.o
OUT = scanner

# Define the build rule for the scanner
$(OUT): $(OBJ)
	$(CXX) -o $(OUT) $(OBJ) -ll

# Define the rule for building the object file
$(OBJ): $(SRC)
	lex -o lex.yy.cpp $(SRC)
	$(CXX) $(CXXFLAGS) -c lex.yy.cpp

# Define a clean rule to remove generated files
clean:
	rm -f $(OBJ) lex.yy.cpp $(OUT)
