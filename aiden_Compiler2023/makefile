all: compiler clean

compiler: lex.yy.cpp symbol.hpp symboltable.hpp y.tab.cpp
	g++ y.tab.cpp symbol.hpp symboltable.hpp -ll -ly -std=c++11 -Wno-deprecated-register

lex.yy.cpp: scanner.l
	lex -o lex.yy.cpp scanner.l

y.tab.cpp: parser.y
	yacc -v -d -o y.tab.cpp parser.y


clean:
	rm lex.yy.cpp *.gch
