%{
#include <stdio.h>
#include <stdlib.h>

extern int yylex();
extern int yyparse();

extern FILE* yyin;
extern int line_number;
extern int column_number; 
void yyerror(const char * s) {
	printf("Error: On line %d, column %d: %s \n", line_number, column_number, s);
}
%}

%error-verbose

%start program

%token INTEGER BREAK CONTINUE IF ELSE WHILE FOR READ WRITE COMMENT RETURN DIGIT ALPHA  
%token ADDITION SUBTRACTION MULTIPLICATION MOD DIVISION
%token OPEN_PARAMETER CLOSE_PARAMETER OPEN_BRACKET CLOSE_BRACKET OPEN_SCOPE CLOSE_SCOPE COMMA END_STATEMENT ASSIGN
%token EQUALS_TO NOT_EQUALS_TO LESS_THAN LESS_THAN_OR_EQUAL_TO GREATER_THAN GREATER_THAN_OR_EQUAL_TO EXTRACT INSERT NOT

%%

program: functions
		| error {yyerrok; yyclearin;}
       		;

functions: /*epsilon*/
		| function functions
		;

function: INTEGER Ident OPEN_PARAMETER declarations CLOSE_PARAMETER OPEN_SCOPE statements CLOSE_SCOPE
		;

declarations: /*epsilon*/
		| declaration COMMA declarations
		| declaration error {yyerrok;}
		;

declaration: identifiers
		;

identifiers: Ident
		| Ident COMMA identifiers
		;

Ident: ALPHA
		;

statements:	statement END_STATEMENT statements
		| statement END_STATEMENT
		| statement error {yyerrok;}
		;

statement: svar
	  	| sif
		| swhile
		| sread
		| swrite
		| scontinue
		| sreturn
		;

svar: var ASSIGN expression
		;

sif: IF OPEN_PARAMETER bool_expr CLOSE_PARAMETER OPEN_SCOPE statements CLOSE_SCOPE
		| IF OPEN_PARAMETER bool_expr CLOSE_PARAMETER OPEN_SCOPE statements CLOSE_SCOPE ELSE OPEN_SCOPE statements CLOSE_SCOPE
		;

swhile: WHILE OPEN_PARAMETER bool_expr CLOSE_PARAMETER OPEN_SCOPE statements CLOSE_SCOPE
		;

sread: READ INSERT ALPHA
		;
     
swrite: WRITE EXTRACT ALPHA
		;

scontinue: CONTINUE
		;

sreturn: RETURN expression
		;

bool_expr: relation_exprs
		;

relation_exprs: relation_expr
		;

relation_expr: NOT ece
		| ece
		| OPEN_SCOPE bool_expr CLOSE_PARAMETER
		;

ece: expression comp expression
		;

comp: EQUALS_TO
		| NOT_EQUALS_TO
		| LESS_THAN
		| GREATER_THAN
		| LESS_THAN_OR_EQUAL_TO
		| GREATER_THAN_OR_EQUAL_TO
		;

expression:	multi_expr addSubExpr
		| error {yyerrok;}
		;

addSubExpr:	/*epsilon*/
		| ADDITION expression
		| SUBTRACTION expression
		;

multi_expr:	term
		| term MULTIPLICATION multi_expr
		| term DIVISION multi_expr
		| term MOD multi_expr
		;

term: SUBTRACTION var
		| var
		| SUBTRACTION DIGIT
		| DIGIT
		| OPEN_PARAMETER expression CLOSE_PARAMETER
		;

var: Ident
		;

%%

int main(int argc, char* argv[]) {
  ++argv;
  --argc;
  
  if(argc>0) 
  {
    yyin = fopen(argv[0], "r");
  }
  else 
  {
    yyin = stdin;
  }
  
  yyparse();

  return 1; 
}
