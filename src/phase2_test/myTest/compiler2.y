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
  
  printf("Ctrl+D to quit. \n");
  yyparse();


  printf("Parenthesis are balanced!\n");
  return 0; 
}

void yyerror(const char* s) {
  fprintf(stderr, "Parse error: %s. Parenthesis are not balanced!\n", s);
  exit(1);
}

