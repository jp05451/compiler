##################################################################
#
#	Makefile -- P Parser
#
##################################################################

parser: y.tab.cpp lex.yy.cpp
	g++  -o parser y.tab.cpp -ll 

y.tab.cpp: parser.y
	bison -o y.tab.cpp parser.y -d -v

lex.yy.cpp: scanner.l
	lex -o lex.yy.cpp scanner.l
	
clean:
	rm -f  lex.yy.cpp y.tab.cpp y.output scanner parser y.tab.hpp
