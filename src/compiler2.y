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
%token INTEGER ADDITION SUBTRACTION MULTIPLICATION MOD DIVISION COMMA END_STATEMENT OPEN_BRACKET OPEN_PARAMETER CLOSE_PARAMETER OPEN_SCOPE CLOSE_SCOPE LESS_THAN LESS_THAN_OR_EQUAL_TO GREATER_THAN GREATER_THAN_OR_EQUAL_TO ASSIGN EQUALS_TO NOT_EQUALS_TO WHILE BREAK CONTINUE IF ELSE READ WRITE COMMENT RETURN DIGIT ALPHA INVALID


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

