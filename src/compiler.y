%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"

extern FILE* yyin;
extern int line_number;
extern int column_number; 
void yyerror(const char * s) {
    printf("Error: On line %d, column %d: %s \n", line_number, column_number, s);
}
%}

struct CodeNode {
        std::string code;
        std::string name;
}

%union {
        char *op_val;
        struct CodeNode *node;
}


%error-verbose
%start prog_start
%token INVALID_TOKEN
%token WRITE READ WHILE BREAK CONTINUE IF ELSE INSERT EXTRACT RETURN INTEGER
%token ALPHA DIGIT
%token ADDITION SUBTRACTION MULTIPLICATION DIVISION MOD ASSIGN
%token EQUALS_TO NOT_EQUALS_TO LESS_THAN GREATER_THAN LESS_THAN_OR_EQUAL_TO GREATER_THAN_OR_EQUAL_TO NOT OPEN_PARAMETER
%token CLOSE_PARAMETER OPEN_SCOPE CLOSE_SCOPE OPEN_BRACKET CLOSE_BRACKET END_STATEMENT COMMA ENDL
%type <node> functions
%type <node> function
%type <node> declarations
%type <node> declaration

%%
prog_start: 
        %empty /* epsilon */ 
        {
        
        } 
        | functions 
        {

        }
        ;

functions: 
        function 
        {

        }
        | function functions 
        {

        }
        ;

function: 
        INTEGER ALPHA OPEN_PARAMETER args CLOSE_PARAMETER OPEN_SCOPE statements CLOSE_SCOPE 
        {

        }
	;

statements: 
        statement statements 
        {

        }
        | %empty 
        {

        }
        ;

statement: 
        int_declaration 
        {

        }
        | array_declaration 
        {

        }
        | print_statement 
        {

        }
        | input_statement 
        {

        }
        | if_statement 
        {

        }
        | while_statement 
        {

        }
        | break_statement 
        {

        }
        | continue_statement 
        {

        }
        | function_call 
        {

        }
        | return_statement 
        {

        }
        | assign_int 
        {

        }
        | assign_array 
        {

        }
        ;

int_declaration: 
        INTEGER ALPHA assign_statement END_STATEMENT 
        {

        }
        ;

array_declaration: 
        INTEGER ALPHA OPEN_BRACKET add_expression CLOSE_BRACKET assign_statement END_STATEMENT 
        {

        }
	;

assign_statement: 
        %empty 
        {

        }
        | ASSIGN add_expression 
        {

        }
        ;

print_statement: 
        WRITE EXTRACT binary_expression END_STATEMENT 
        {

        }
        | 
        WRITE EXTRACT binary_expression EXTRACT ENDL END_STATEMENT 
        {

        }
        ;

input_statement: 
        READ INSERT ALPHA END_STATEMENT 
        {
                
        }
        ;

if_statement: 
        IF expression OPEN_SCOPE statements CLOSE_SCOPE else_statement 
        {
                
        }
        ;

else_statement: 
        ELSE OPEN_SCOPE statements CLOSE_SCOPE 
        {

        }
        | %empty 
        {

        }
        ;

while_statement: 
        WHILE OPEN_PARAMETER binary_expression CLOSE_PARAMETER OPEN_SCOPE statements CLOSE_SCOPE 
        {

        }
        ;

break_statement: 
        BREAK END_STATEMENT 
        {

        }
        ;  

continue_statement: 
        CONTINUE END_STATEMENT 
        {

        }
        ;

expression: 
        DIGIT 
        {

        }    
        | OPEN_PARAMETER binary_expression CLOSE_PARAMETER 
        {

        }  
        | ALPHA 
        {

        }
        | ALPHA OPEN_BRACKET add_expression CLOSE_BRACKET 
        {

        }
        | function_call 
        {

        }
        ;

binary_expression: 
        add_expression {printf("binary_expression -> add_expression\n");}
        | binary_expression EQUALS_TO add_expression 
        {
                
        }
        | binary_expression NOT add_expression 
        {
                
        }
        | binary_expression LESS_THAN add_expression 
        {
                
        }
        | binary_expression LESS_THAN_OR_EQUAL_TO add_expression 
        {

        }
        | binary_expression GREATER_THAN add_expression 
        {

        }
        | binary_expression GREATER_THAN_OR_EQUAL_TO add_expression 
        {

        }
        ;

add_expression: mult_expression 
        {

        }
        | add_expression ADDITION mult_expression 
        {

        }
        | add_expression SUBTRACTION mult_expression 
        {

        }
        ;

mult_expression: 
        base_expression 
        {

        }
        | mult_expression MULTIPLICATION base_expression 
        {

        }
        | mult_expression DIVISION base_expression 
        {

        }
        | mult_expression MOD base_expression 
        {

        }
        ;

base_expression: 
        expression 
        {

        }
        ;

assign_int: 
        ALPHA ASSIGN add_expression END_STATEMENT 
        {
                
        }
        ;

assign_array: 
        ALPHA OPEN_BRACKET DIGIT CLOSE_BRACKET ASSIGN add_expression END_STATEMENT 
        {
                
        }
        ;

function_call: 
        ALPHA OPEN_PARAMETER param CLOSE_PARAMETER 
        {
        
        }

param: 
        binary_expression params 
        {

        }
        | %empty {printf("param -> epsilon\n");}
        ;

params: 
        COMMA binary_expression params 
        {
                
        }
        | %empty 
        {
                
        }
        ;

args: 
        arg repeat_args 
        {

        } 
        | %empty 
        {

        }
        ;

repeat_args: 
        COMMA arg repeat_args 
        {
                
        }
        | %empty 
        {
                
        }
        ;

arg: 
        INTEGER ALPHA 
        {
                
        }
        ;

return_statement: 
        RETURN return_expression END_STATEMENT 
        {
                
        }
        ;

return_expression: 
        add_expression 
        {
                
        }
        | %empty 
        {

        }
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