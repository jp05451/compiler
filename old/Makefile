##################################################################
#
#	Makefile -- P Parser
#
##################################################################

parser: y.tab.cpp lex.yy.cpp
	g++ -o parser y.tab.cpp -ll

lex.yy.cpp: scanner.l
	lex -o lex.yy.cpp scanner.l

y.tab.cpp: parser.y
	yacc -o y.tab.cpp parser.y -d -v

clean:
	rm -f  lex.yy.cpp y.tab.cpp y.output scanner parser y.tab.hpp
