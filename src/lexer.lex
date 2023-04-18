%{
#include <stdio.h>
int line_number = 0;
int column_number = 0;
%} 

DIGIT [0-9] 
ALPHA [a-zA-z]
%%

{DIGIT} | {ALPHA} {printf(UNION: %s,\n", yytext)};
{DIGIT}{ALPHA} {printf("CONCATENATE: ");};
{DIGIT}+ {printf("NUMBER: %s\n", yytext);
        column_number += yyleng;
   } 
{ALPHA}+ {printf("STRING: %s\n", yytext);
        column_number += yyleng;
   } 
" "       {column_number += yyleng;}
"\n"       {column_number = 0, line_number++;}
.      {printf("Error at line %d, column %d: Unidentified '%s'\n",
line_number,
column_number,
yytext);} 

%%

int main(void) {
    printf("Ctrl+D to quit. \n");
    printf("Hello! My name is %s\n", "Daniel");
    yylex(); 
}
