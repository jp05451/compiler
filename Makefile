all: compiler clean

compiler: lex.yy.cpp symbol.hpp symbolTable.hpp y.tab.cpp symbolStack.hpp
	g++ y.tab.cpp  -ll  -std=c++17 -Wno-deprecated-register

lex.yy.cpp: scanner.l
	lex -o lex.yy.cpp scanner.l

y.tab.cpp: parser.y
	yacc -v -d -o y.tab.cpp parser.y


clean:
	rm lex.yy.cpp