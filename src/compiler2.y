%{
    #include <iostream>
    #include <stdio.h>
    #include <string>
    using namesapce std; 
    int yyerror(char *s);
    int yylex(void);
    extern FILE* yyin;
%}

%start prog_start
%token INT SMICOLON IDENT LBR RBR COMMA LPR RPR

%%
Prog_start: %empty {printf(“prog_start -> epsilon \n”);}
 | functions {printf(“prog_start -> function \n”);}
 ;
 
Functions: function {printf(“functions -> function”);}
| function functions
;

Function: INT IDENT LPR arguments RPR LBR statements RBR
	{printf(“function -> INT IDENT LPR arguments RPR LBR statements RBR”);}

Arguments: %empty
	| argument COMMA arguments
	;

Argument: INT IDENT {printf(“argument -> INT IDENT”);}

Statements: %empty
	| statement statements

Statement: decl
	| function_call

Decl: INT IDENT

function_call : IDENT LPR params RPR

%%

Return the tokens, you include y.tab.h file to declare the tokens in bison.
Do global variable stuff before the return obviously. 


Move the main function and put it in the bison file.
Change yylex() to yyparse()

Example main() (given)

Void main(int argc, char**argv) {
	if(argc>=2) {
		yyin = fopen(argv[1], “r”);
		if(yyin == NULL) {
			Yyin = stdin;
		}
	}
else{
Yyin = stdin;
}
yyparse();
}

