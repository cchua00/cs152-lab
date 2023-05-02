%option noyywrap

%{
#include <stdio.h>
#include "compiler2.tab.h"
int line_number = 0;
int column_number = 0;
%} 

INTEGER "int"
ADDITION "+"
SUBTRACTION "-"
MULTIPLICATION "*"
MOD "%"
DIVISION "/"
COMMA ","
END_STATEMENT ";"
OPEN_BRACKET "["
CLOSE_BRACKET "]"
OPEN_PARAMETER "("
CLOSE_PARAMETER ")"
OPEN_SCOPE "{"
CLOSE_SCOPE "}"
LESS_THAN "<"
LESS_THAN_OR_EQUAL_TO "<="
GREATER_THAN ">"
GREATER_THAN_OR_EQUAL_TO ">="
ASSIGN "="
EQUALS_TO "=="
NOT_EQUALS_TO "!="
NOT "!"
WHILE "while"
BREAK "break"
CONTINUE "continue"
IF "if"
ELSE "else"
READ "cin"
WRITE "cout"
INSERT ">>"
EXTRACT "<<"
COMMENT "//"([ \t]?.)*
RETURN "return"

DIGIT [0-9]
ALPHA [a-zA-z]*
INVALID [0-9]+{ALPHA}

%%

{INTEGER} {printf("INTEGER\n", yytext); column_number += yyleng;}
{ADDITION} {printf("ADDITION\n", yytext); column_number += yyleng;}
{SUBTRACTION} {printf("SUBTRACTION\n", yytext); column_number += yyleng;}
{MULTIPLICATION} {printf("MULTIPLICATION\n", yytext); column_number += yyleng;}
{MOD} {printf("MOD\n", yytext); column_number += yyleng;}
{DIVISION} {printf("DIVISION\n", yytext); column_number += yyleng;}
{COMMA} {printf("COMMA\n", yytext); column_number += yyleng;}
{END_STATEMENT} {printf("END_STATEMENT\n", yytext); column_number += yyleng;}
{OPEN_BRACKET} {printf("OPEN_BRACKET\n", yytext); column_number += yyleng;}
{CLOSE_BRACKET} {printf("CLOSE_BRACKET\n", yytext); column_number += yyleng;}
{OPEN_PARAMETER} {printf("OPEN_PARAMETER\n", yytext); column_number += yyleng;}
{CLOSE_PARAMETER} {printf("CLOSE_PARAMETER\n", yytext); column_number += yyleng;}
{OPEN_SCOPE} {printf("OPEN_SCOPE\n", yytext); column_number += yyleng;}
{CLOSE_SCOPE} {printf("CLOSE_SCOPE\n", yytext); column_number += yyleng;}
{LESS_THAN} {printf("LESS_THAN\n", yytext); column_number += yyleng;}
{LESS_THAN_OR_EQUAL_TO} {printf("LESS_THAN_OR_EQUAL_TO\n", yytext); column_number += yyleng;}
{GREATER_THAN} {printf("GREATER_THAN\n", yytext); column_number += yyleng;}
{GREATER_THAN_OR_EQUAL_TO} {printf("GREATER_THAN_OR_EQUAL_TO\n", yytext); column_number += yyleng;}
{ASSIGN} {printf("ASSIGN\n", yytext); column_number += yyleng;}
{EQUALS_TO} {printf("EQUALS_TO\n", yytext); column_number += yyleng;}
{NOT_EQUALS_TO} {printf("NOT_EQUALS_TO\n", yytext); column_number += yyleng;}
{NOT} {printf("NOT\n", yytext); column_number += yyleng;}
{WHILE} {printf("WHILE\n", yytext); column_number += yyleng;}
{BREAK} {printf("BREAK\n", yytext); column_number += yyleng;}
{CONTINUE} {printf("CONTINUE\n", yytext); column_number += yyleng;}
{IF} {printf("IF\n", yytext); column_number += yyleng;}
{ELSE} {column_number += yyleng; return ELSE;}
{READ} {printf("READ\n", yytext); column_number += yyleng;}
{WRITE} {printf("WRITE\n", yytext); column_number += yyleng;}
{INSERT} {printf("INSERT\n", yytext); column_number += yyleng;}
{EXTRACT} {printf("EXTRACT\n", yytext); column_number += yyleng;}
{COMMENT} {printf("COMMENT\n", yytext); column_number += yyleng;}
{RETURN} {printf("RETURN\n", yytext); column_number += yyleng;}

[+-]?{DIGIT}+ {printf("NUMBER: %s\n", yytext); column_number += yyleng; yyless(yyleng);} 
{ALPHA}+ {printf("Identifier: %s\n", yytext);column_number += yyleng;}
{INVALID} {printf("%d, %d, %s", line_number, column_number, yytext);}
" " {column_number += yyleng;}
"\n" {column_number = 0, line_number++;}
. {printf("Error at line %d, column %d: Unidentified '%s'\n", line_number, column_number, yytext);} 

%%


