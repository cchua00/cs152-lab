%{
#include <stdio.h>
#include <stdlib.h>

extern int yylex();
extern int yyparse();
extern FILE* yyin;


void yyerror(const char* s);
%}

%left OPEN_PARAMETER CLOSE_PARAMETER 

%start expr 

%%

expr: OPEN_PARAMETER expr CLOSE_PARAMETER expr 
    | %empty
;

%%

int main() {
  yyin = stdin;

  do {
    printf("Parse.\n");
    yyparse();
  } while(!feof(yyin));
  printf("Parenthesis are balanced!\n");
  return 0;
}

void yyerror(const char* s) {
  fprintf(stderr, "Parse error: %s. Parenthesis are not balanced!\n", s);
  exit(1);
}

