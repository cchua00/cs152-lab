%{
#include "y.tab.h"
#include <string.h>
int line_number = 1;
int column_number = 1;
%} 

%%

"+" {column_number += yyleng; return ADDITION;}
"-" {column_number += yyleng; return SUBTRACTION;}
"*" {column_number += yyleng; return MULTIPLICATION;}
"%" {column_number += yyleng; return MOD;}
"/" {column_number += yyleng; return DIVISION;}
"," {column_number += yyleng; return COMMA;}
";" {column_number += yyleng; return END_STATEMENT;}
"[" {column_number += yyleng; return OPEN_BRACKET;}
"]" {column_number += yyleng; return CLOSE_BRACKET;}
"(" {column_number += yyleng; return OPEN_PARAMETER;}
")" {column_number += yyleng; return CLOSE_PARAMETER;}
"{" {column_number += yyleng; return OPEN_SCOPE;}
"}" {column_number += yyleng; return CLOSE_SCOPE;}
"<" {column_number += yyleng; return LESS_THAN;}
"<=" {column_number += yyleng; return LESS_THAN_OR_EQUAL_TO;}
">" {column_number += yyleng; return GREATER_THAN;}
">=" {column_number += yyleng; return GREATER_THAN_OR_EQUAL_TO;}
"=" {column_number += yyleng; return ASSIGN;}
"==" {column_number += yyleng; return EQUALS_TO;}
"!" {column_number += yyleng; return NOT;}
int {column_number += yyleng; return INTEGER;}
while {column_number += yyleng; return WHILE;}
break {column_number += yyleng; return BREAK;}
continue {column_number += yyleng; return CONTINUE;}
if {column_number += yyleng; return IF;}
else {column_number += yyleng; return ELSE;}
cin {column_number += yyleng; return READ;}
cout {column_number += yyleng; return WRITE;}
">>" {column_number += yyleng; return INSERT;}
"<<" {column_number += yyleng; return EXTRACT;}
return {column_number += yyleng; return RETURN;}
endl {column_number += yyleng; return ENDL;}

(##).* {column_number = 1;}

[0-9]+ {column_number += yyleng; return DIGIT;}

[0-9_][a-zA-Z0-9_]*[a-zA-Z0-9_] {printf("Error at line %d, column %d: identifier \"%s\" must begin with a letter\n", column_number, line_number, yytext); exit(0);}
[a-zA-Z0-9_]*[_] {printf("Error at line %d, column %d: identifier \"%s\" cannot end with an underscore\n", column_number, line_number, yytext); exit(0);}

[a-zA-Z0-9_]*[a-zA-Z0-9]* {
    column_number += yyleng;
    
    char* token = new char[yyleng];
    strcpy(token, yytext);
    yylval.op_val = token; 
    return ALPHA;
    }

[ ]+ {column_number += yyleng;}
[\t]+ {column_number += yyleng;}
"\n" {line_number++; column_number = 1;}
"//"([ \t]?.)*   {/*ignore comment*/ line_number++; column_number = 1; }
. {printf("Error at line %d. column %d: unrecognized symbol \"%s\"\n", line_number, column_number, yytext); exit(0);}

%%

