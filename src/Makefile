all: compiler2
compiler2.tab.c compiler2.tab.h:	compiler2.y
	bison -t -v -d compiler2.y
lex.yy.c: lexer.lex compiler2.tab.h
	flex lexer.lex 
compiler2: lex.yy.c compiler2.tab.c compiler2.tab.h
	g++ -o compiler2 compiler2.tab.c lex.yy.c
clean:
	rm compiler2 compiler2.tab.c lex.yy.c compiler2.tab.h compiler2.output