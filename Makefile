all: compiler clean

compiler: lex.yy.cpp symbol.hpp symboltable.hpp y.tab.cpp
	g++ -o parser y.tab.cpp symbol.hpp symboltable.hpp -ll -ly -std=c++17 -Wno-deprecated-register

lex.yy.cpp: scanner.l
	lex -o lex.yy.cpp scanner.l

y.tab.cpp: parser.y
	bison -v -d -o y.tab.cpp parser.y


clean:
	rm lex.yy.cpp *.gch
