%{
#include <stdio.h>
extern FILE* yyin;
extern int line_number;
extern int column_number; 
void yyerror(const char * s) {
    printf("Error: On line %d, column %d: %s \n", line_number, column_number, s);
}
%}

%error-verbose
%start prog_start

%token WRITE READ WHILE BREAK CONTINUE IF ELSE INSERT EXTRACT RETURN INTEGER
%token ALPHA DIGIT
%token ADDITION SUBTRACTION MULTIPLICATION DIVISION MOD ASSIGN
%token EQUALS_TO LESS_THAN GREATER_THAN LESS_THAN_OR_EQUAL_TO GREATER_THAN_OR_EQUAL_TO NOT OPEN_PARAMETER
%token CLOSE_PARAMETER OPEN_SCOPE CLOSE_SCOPE OPEN_BRACKET CLOSE_BRACKET END_STATEMENT COMMA ENDL

%%
prog_start: functions {printf("prog_start -> functions\n");}
        | %empty /* epsilon */ {printf("prog_start->epsilon\n");}
        ;

functions: function {printf("functions -> function\n");}
        | function functions {printf("functions -> function functions\n");}
        ;

function: INTEGER ALPHA OPEN_PARAMETER args CLOSE_PARAMETER OPEN_SCOPE statements CLOSE_SCOPE {printf("function -> INTEGER ALPHA OPEN_PARAMETER arguments CLOSE_PARAMETER OPEN_SCOPE statements CLOSE_SCOPE\n");}
	    ;

statements: statement statements {printf("statements -> statement statements\n");}
        | %empty /* epsilon */ {printf("statements -> epsilon\n");}
        ;

statement: int_declaration {printf("statement -> var_declaration\n");}
        | array_declaration {printf("statement -> array_declaration\n");}
        | print_statement {printf("statement -> print_statement\n");}
        | input_statement {printf("statement -> input_statement\n");}
        | if_statement {printf("statement -> if_statement\n");}
        | while_statement {printf("statement -> while_statement\n");}
        | break_statement {printf("statement -> break_statement\n");}
        | continue_statement {printf("statement -> continue_statement\n");}
        | function_call {printf("statement -> function_call\n");}
        | return_statement {printf("statement -> return_statement\n");}
        | assign_int
        | assign_array
        ;

int_declaration: INTEGER ALPHA assign_statement END_STATEMENT {printf("var_declaration -> INTEGER ALPHA END_STATEMENT\n");}
                ;

array_declaration: INTEGER ALPHA OPEN_BRACKET add_expression CLOSE_BRACKET assign_statement END_STATEMENT {printf("var_declaration -> INTEGER ALPHA OPEN_BRACKET DIGIT CLOSE_BRACKET\n");}
	        ;

assign_statement: %empty
                | ASSIGN add_expression
                ;

print_statement: WRITE EXTRACT binary_expression END_STATEMENT {printf("print_statement -> WRITE EXTRACT ALPHA END_STATEMENT\n");}
                | WRITE EXTRACT binary_expression EXTRACT ENDL END_STATEMENT {printf("print_statement -> WRITE EXTRACT ALPHA EXTRACT ENDL END_STATEMENT\n");}
                ;

input_statement: READ INSERT ALPHA END_STATEMENT {printf("input_statement -> READ OPEN_PARAMETER CLOSE_PARAMETER\n");}
                ;

if_statement: IF expression OPEN_SCOPE statements CLOSE_SCOPE else_statement {printf("if_statement -> IF expression OPEN_SCOPE statement CLOSE_SCOPE ELSE OPEN_SCOPE statement CLOSE_SCOPE\n");}
            ;

else_statement: ELSE OPEN_SCOPE statements CLOSE_SCOPE
            | %empty
            ;

while_statement: WHILE OPEN_PARAMETER binary_expression CLOSE_PARAMETER OPEN_SCOPE statements CLOSE_SCOPE {printf("while_statement -> WHILE expression OPEN_SCOPE statements CLOSE_SCOPE\n");}
                ;

break_statement: BREAK END_STATEMENT {printf("break_statement -> BREAK END_STATEMENT\n");}
                ;  

continue_statement: CONTINUE END_STATEMENT {printf("continue_statement -> CONTINUE END_STATEMENT\n");}
                ;

expression: DIGIT {printf("expression -> DIGIT\n");}    
        | OPEN_PARAMETER binary_expression CLOSE_PARAMETER 
        | ALPHA {printf("expression -> ALPHA\n");}
        | ALPHA OPEN_BRACKET add_expression CLOSE_BRACKET {printf("expression -> ALPHA OPEN_BRACKET DIGIT CLOSE_BRACKET\n");}
        | function_call {printf("expression -> function_call\n");}
        ;

binary_expression: add_expression
                | binary_expression EQUALS_TO add_expression {printf("binary_expression -> expression EQUALS_TO expression\n");}
                | binary_expression NOT add_expression {printf("binary_expression -> expression NOT expression\n");}
                | binary_expression LESS_THAN add_expression {printf("binary_expression -> expression LESS_THAN expression\n");}
                | binary_expression LESS_THAN_OR_EQUAL_TO add_expression {printf("binary_expression -> expression LESS_THAN_OR_EQUAL_TO expression\n");}
                | binary_expression GREATER_THAN add_expression {printf("binary_expression -> expression GREATER_THAN expression\n");}
                | binary_expression GREATER_THAN_OR_EQUAL_TO add_expression {printf("binary_expression -> expression GREATER_THAN_OR_EQUAL_TO expression\n");}
                ;

add_expression: mult_expression
        | add_expression ADDITION mult_expression
        | add_expression SUBTRACTION mult_expression
        ;

mult_expression: base_expression
        | mult_expression MULTIPLICATION base_expression
        | mult_expression DIVISION base_expression
        | mult_expression MOD base_expression
        ;

base_expression: expression
        ;

assign_int: ALPHA ASSIGN add_expression END_STATEMENT
             ;

assign_array: ALPHA OPEN_BRACKET DIGIT CLOSE_BRACKET ASSIGN add_expression END_STATEMENT
               ;

function_call: ALPHA OPEN_PARAMETER param CLOSE_PARAMETER {printf("function_call -> ALPHA OPEN_PARAMETER args CLOSE_PARAMETER END_STATEMENT\n");}

param: binary_expression params {printf("param -> binary_expression params\n");}
          | %empty                     {printf("param -> epsilon\n");}
          ;

params: COMMA binary_expression params {printf("params -> COMMA binary_expression params\n");}
        | %empty                           {printf("params -> epsilon\n");}
        ;

args: arg repeat_args {printf("args -> arg repeat_args\n");} 
    | %empty {printf("args -> epsilon\n");}
    ;

repeat_args: COMMA arg repeat_args {printf("repeat_args -> COMMA arg repeat_args\n");}
        | %empty        
        ;

arg: INTEGER ALPHA {printf("argument -> expression\n");}
        ;

return_statement: RETURN return_expression END_STATEMENT {printf("return_statement -> RETURN expression END_STATEMENT\n");}
                ;

return_expression: add_expression
                | %empty
                ;

%%

void main(int argc, char** argv) {
	if (argc >= 2) {
		yyin = fopen(argv[1], "r");
		if (yyin == NULL)
			yyin = stdin;
	}
	else {
		yyin = stdin;
	}
	yyparse();
}