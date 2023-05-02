%{
#include <stdio.h>
#include <stdlib.h>

extern int yylex();
extern int yyparse();
extern FILE* yyin;


void yyerror(const char* s);
%}

%token INTEGER BREAK CONTINUE IF ELSE WHILE FOR READ WRITE COMMENT RETURN DIGIT ALPHA  
%token ADDITION SUBTRACTION MULTIPLICATION MOD DIVISION
%token OPEN_PARAMETER CLOSE_PARAMETER OPEN_BRACKET CLOSE_BRACKET OPEN_SCOPE CLOSE_SCOPE COMMA END_STATEMENT ASSIGN
%token EQUALS_TO NOT_EQUALS_TO LESS_THAN LESS_THAN_OR_EQUAL_TO GREATER_THAN GREATER_THAN_OR_EQUAL_TO EXTRACT INSERT NOT


%start program 


%%
program: function ;

function: variable OPEN_PARAMETER variable CLOSE_PARAMETER END_STATEMENT
    | variable OPEN_PARAMETER variable CLOSE_PARAMETER OPEN_SCOPE statement CLOSE_SCOPE
    ;

declaration: variable END_STATEMENT
    | variable END_STATEMENT
    ;

statement: variable ASSIGN expr END_STATEMENT
    | IF OPEN_PARAMETER boolexpr CLOSE_PARAMETER OPEN_SCOPE statement END_STATEMENT CLOSE_SCOPE
    | IF OPEN_PARAMETER boolexpr CLOSE_PARAMETER OPEN_SCOPE statement END_STATEMENT CLOSE_SCOPE ELSE OPEN_SCOPE statement END_STATEMENT CLOSE_SCOPE 
    | WHILE OPEN_PARAMETER variable CLOSE_PARAMETER OPEN_SCOPE statement END_STATEMENT CLOSE_SCOPE
    | READ INSERT variable
    | WRITE EXTRACT variable
    | CONTINUE
    | BREAK
    | RETURN expr 
    ;

boolexpr: NOT boolexpr
    | expr comp expr
    ;

comp: EQUALS_TO
    | NOT_EQUALS_TO
    | GREATER_THAN
    | LESS_THAN
    | GREATER_THAN_OR_EQUAL_TO
    | LESS_THAN_OR_EQUAL_TO 
    ;
    
expr: mulop ADDITION mulop
    | mulop SUBTRACTION mulop
    ;

mulop: term MULTIPLICATION term
    | term DIVISION term
    | term MOD term
    ;

term: variable
    | DIGIT
    | OPEN_PARAMETER expr CLOSE_PARAMETER
    | ALPHA
    | ALPHA OPEN_PARAMETER expr CLOSE_PARAMETER
    ;

variable: INTEGER ALPHA
    | INTEGER ALPHA OPEN_BRACKET expr CLOSE_BRACKET
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


  printf("Hello World!\n");
  return 0; 
}

void yyerror(const char* s) {
  fprintf(stderr, "Syntax Error on line %s. \n", s);
}

