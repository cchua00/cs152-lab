%{
    #include <stdio.h>
    extern FILE* yyin;
%}

%start prog_start
%token INT SMICOLON IDENT LBR RBR COMMA LPR RPR

%%
Prog_start: %empty {printf(“prog_start -> epsilon \n”);}
 | functions {printf(“prog_start -> function \n”);}
 ;
 
