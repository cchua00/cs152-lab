CXXFLAGS += -std=c++11

all:
	flex compiler.lex
	bison -v -d --file-prefix=y compiler.y
	g++ $(CXXFLAGS) -o parser lex.yy.c y.tab.c -lfl
	
clean:
	rm -f parser lex.yy.c y.tab.c y.tab.h y.output *.mil mil_run
