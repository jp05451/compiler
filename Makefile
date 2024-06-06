##################################################################
#
#	Makefile -- P Parser
#
##################################################################

parser: y.tab.cpp lex.yy.cpp
	g++ -ll -std=c++17 -o parser y.tab.cpp 

lex.yy.cpp: scanner.l
	lex -o lex.yy.cpp scanner.l

y.tab.cpp: parser.y
	bison -o y.tab.cpp parser.y -d -v

clean:
	rm -f  lex.yy.cpp y.tab.cpp y.output scanner parser y.tab.hpp
