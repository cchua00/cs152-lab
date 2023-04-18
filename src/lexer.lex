%{
#include <stdio.h>
int line_number = 0;
int column_number = 0;
%} 

DIGIT [0-9] 
ALPHA [a-zA-z]
SEMICOLON [;]
L_BRACKET [[]
R_BRACKET []]
L_PAREN [(]
R_PAREN [)]
L_CURLY [{]
R_CURLY [}]
ASSIGN [=]
PLUS [+]
MINUS [-]
MULTIPLY [*]
LESSTHAN [<]
GREATERTHAN [>]
DIVIDE [/]

QUOTE["]
COMMA [,]
PERIOD [.]
COLON [:]
PERCENT [%]
%%

{DIGIT}+ {printf("NUMBER: %s\n", yytext);
        column_number += yyleng;
   } 
{ALPHA}+   { }
{SEMICOLON} {printf("SEMICOLON\n", yytext);}
{L_BRACKET} {printf("L_BRACKET\n", yytext);}
{R_BRACKET} {printf("R_BRACKET\n", yytext);}
{L_PAREN} {printf("L_PAREN\n", yytext);}
{R_PAREN} {printf("R_PAREN\n", yytext);}
{L_CURLY} {printf("L_CURLY\n", yytext);}
{R_CURLY} {printf("R_CURLY\n", yytext);}
{ASSIGN} {printf("ASSIGN\n", yytext);}
{PLUS} {printf("PLUS\n", yytext);}
{MINUS} {printf("MINUS\n", yytext);}
{MULTIPLY} {printf("MULTPLY\n", yytext);}
{DIVIDE} {printf("DIVIDE\n", yytext);}
{LESSTHAN} {printf("LESSTHAN\n", yytext);}
{GREATERTHAN} {printf("GREATERTHAN\n", yytext);}

{QUOTE} {printf("QUOTE\n", yytext);}
{COMMA} {printf("COMMA\n", yytext);}
{PERIOD} {printf("PERIOD\n", yytext);}
{COLON} {printf("COLON\n", yytext);}
{PERCENT} {printf("PERCENT\n", yytext);}

" "       {column_number += yyleng;}
"\n"       {column_number = 0, line_number++;}
.      {printf("Error at line %d, column %d: Unidentified '%s'\n",
line_number,
column_number,
yytext);} 

%%

int main(void) {
    printf("Ctrl+D to quit. \n");
    yylex(); 
}
