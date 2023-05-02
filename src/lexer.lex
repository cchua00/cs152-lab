%option noyywrap

%{
#include "compiler2.tab.h"
int line_number = 0;
int column_number = 1;
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
ENDL "endl"

DIGIT [0-9]

ALPHA [a-zA-Z][a-zA-Z0-9]*   
INVALID [0-9]+{ALPHA} 
INVALID1 [0-9]+[a-zA-Z][a-zA-Z0-9]*|[a-zA-Z]_[a-zA-Z0-9]*|[+-]?[0-9]+
%%

{INTEGER} {column_number += yyleng; return INTEGER;}
{ADDITION} {column_number += yyleng; return ADDITION;}
{SUBTRACTION} {column_number += yyleng; return SUBTRACTION;}
{MULTIPLICATION} {column_number += yyleng; return MULTIPLICATION;}
{MOD} {column_number += yyleng; return MOD;}
{DIVISION} {column_number += yyleng; return DIVISION;}
{COMMA} {column_number += yyleng; return COMMA;}
{END_STATEMENT} {column_number += yyleng; return END_STATEMENT;}
{OPEN_BRACKET} {column_number += yyleng; return OPEN_BRACKET;}
{CLOSE_BRACKET} {column_number += yyleng; return CLOSE_BRACKET;}
{OPEN_PARAMETER} {column_number += yyleng; return OPEN_PARAMETER;}
{CLOSE_PARAMETER} {column_number += yyleng; return CLOSE_PARAMETER;}
{OPEN_SCOPE} {column_number += yyleng; return OPEN_SCOPE;}
{CLOSE_SCOPE} {column_number += yyleng; return CLOSE_SCOPE;}
{LESS_THAN} {column_number += yyleng; return LESS_THAN;}
{LESS_THAN_OR_EQUAL_TO} {column_number += yyleng; return LESS_THAN_OR_EQUAL_TO;}
{GREATER_THAN} {column_number += yyleng; return GREATER_THAN;}
{GREATER_THAN_OR_EQUAL_TO} {column_number += yyleng; return GREATER_THAN_OR_EQUAL_TO;}
{ASSIGN} {column_number += yyleng; return ASSIGN;}
{EQUALS_TO} {column_number += yyleng; return EQUALS_TO;}
{NOT_EQUALS_TO} {column_number += yyleng; return NOT_EQUALS_TO;}
{NOT} {column_number += yyleng; return NOT;}
{WHILE} {column_number += yyleng; return WHILE;}
{BREAK} {column_number += yyleng; return BREAK;}
{CONTINUE} {column_number += yyleng; return CONTINUE;}
{IF} {column_number += yyleng; return IF;}
{ELSE} {column_number += yyleng; return ELSE;}
{READ} {column_number += yyleng; return READ;}
{WRITE} {column_number += yyleng; return WRITE;}
{INSERT} {column_number += yyleng; return INSERT;}
{EXTRACT} {column_number += yyleng; return EXTRACT;}
{COMMENT} {column_number += yyleng; return COMMENT;}
{RETURN} {column_number += yyleng; return RETURN;}
{ENDL} {column_number += yyleng; return ENDL;}

[+-]?{DIGIT}+ {column_number += yyleng; return DIGIT;} 
{ALPHA} {column_number += yyleng; return ALPHA;}
[0-9_][a-zA-Z0-9_]*[a-zA-Z0-9_]  {printf("Error at line %d, column %d: identifier \"%s\" must begin with a letter\n", column_number, line_number, yytext); exit(0);}   
{ALPHA}*[_] {printf("Error at line %d, column %d: identifier \"%s\" cannot end with an underscore\n", column_number, line_number, yytext);exit(0);}

" " {column_number += yyleng;}
"\n" {column_number = 0, line_number++;}
. {printf("Error at line %d, column %d: Unidentified '%s'\n", line_number, column_number, yytext);} 
  
%%


