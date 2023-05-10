%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"

extern FILE* yyin;
extern int yylex();
extern int yylineno;
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

function_call: 
        ALPHA OPEN_PARAMETER args CLOSE_PARAMETER 
        {

        }

functions: 
        function 
        {

        }
        | function functions 
        {

        }
        ;

function: 
        INTEGER ALPHA OPEN_PARAMETER arguments CLOSE_PARAMETER OPEN_SCOPE statements CLOSE_SCOPE 
        {

        }
	;

arguments: 
        %empty 
        {

        }
        | argument repeat_arguments 
        {

        }
        ;

repeat_arguments: 
        %empty 
        {

        }
        | COMMA argument repeat_arguments {printf("repeat_arguments -> COMMA argument repeat_arguments\n");}
        ;

argument: 
        ALPHA 
        {

        }
        | expression 
        {

        }
        | INTEGER ALPHA 
        {

        }
	;

statements: 
        %empty /* epsilon */ 
        {

        }
        | statement statements 
        {

        }
        ;

statement: 
        var_declaration 
        {

        }
        | assign_statement 
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
        ;

var_declaration: 
        INTEGER ALPHA END_STATEMENT 
        {

        }
        | INTEGER ALPHA repeat_arguments END_STATEMENT 
        {

        }
        | INTEGER ALPHA ASSIGN DIGIT END_STATEMENT 
        {

        }
        | INTEGER ALPHA OPEN_BRACKET DIGIT CLOSE_BRACKET END_STATEMENT 
        {

        }
        ;

assign_statement: 
        ALPHA ASSIGN expression END_STATEMENT 
        {

        }
        | expression ASSIGN expression END_STATEMENT 
        {

        }
        ;

print_statement: 
        WRITE EXTRACT ALPHA END_STATEMENT 
        {

        }
        | WRITE EXTRACT ALPHA EXTRACT ENDL END_STATEMENT {

        }
        | WRITE EXTRACT DIGIT END_STATEMENT 
        {}
                | WRITE EXTRACT DIGIT EXTRACT ENDL END_STATEMENT {printf("print_statement -> WRITE EXTRACT DIGIT EXTRACT ENDL END_STATEMENT\n");}
                | WRITE EXTRACT ALPHA OPEN_BRACKET DIGIT CLOSE_BRACKET END_STATEMENT {printf("print_statement -> WRITE EXTRACT ALPHA OPEN_BRACKET DIGIT CLOSE_BRACKET END_STATEMENT\n");}
                | WRITE EXTRACT ALPHA OPEN_BRACKET DIGIT CLOSE_BRACKET EXTRACT ENDL END_STATEMENT {printf("print_statement -> WRITE EXTRACT ALPHA OPEN_BRACKET DIGIT CLOSE_BRACKET EXTRACT ENDL END_STATEMENT\n");}


input_statement: READ INSERT ALPHA END_STATEMENT {printf("input_statement -> READ OPEN_PARAMETER CLOSE_PARAMETER\n");}
                ;

if_statement: IF OPEN_PARAMETER expression CLOSE_PARAMETER OPEN_SCOPE statements CLOSE_SCOPE {printf("if_statement -> IF OPEN_PARAMETER expression CLOSE_PARAMETER OPEN_SCOPE statement CLOSE_SCOPE\n");}
            | IF OPEN_PARAMETER expression CLOSE_PARAMETER OPEN_SCOPE statements CLOSE_SCOPE ELSE OPEN_SCOPE statements CLOSE_SCOPE {printf("if_statement -> IF OPEN_PARAMETER expression CLOSE_PARAMETER OPEN_SCOPE statement CLOSE_SCOPE ELSE OPEN_SCOPE statement CLOSE_SCOPE\n");}
            ;

while_statement: WHILE OPEN_PARAMETER expression CLOSE_PARAMETER OPEN_SCOPE statements CLOSE_SCOPE {printf("while_statement -> WHILE OPEN_PARAMETER expression CLOSE_PARAMETER OPEN_SCOPE statements CLOSE_SCOPE\n");}
                ;

break_statement: BREAK END_STATEMENT {printf("break_statement -> BREAK END_STATEMENT\n");}
                ;  

continue_statement: CONTINUE END_STATEMENT {printf("continue_statement -> CONTINUE END_STATEMENT\n");}
                ;

expression: ALPHA {printf("expression -> ALPHA\n");}
        | DIGIT {printf("expression -> DIGIT\n");}
        | ALPHA OPEN_BRACKET DIGIT CLOSE_BRACKET {printf("expression -> ALPHA OPEN_BRACKET DIGIT CLOSE_BRACKET\n");}
        | OPEN_PARAMETER binary_expression CLOSE_PARAMETER {printf("expression -> (binary_expression)\n");}
        | input_statement {printf("expression -> input_statement\n");}
        | function_call {printf("expression -> function_call\n");}
        | binary_expression {printf("expression -> binary_expression\n");}
        ;

binary_expression: expression ADDITION expression {printf("binary_expression -> expression ADDITION expression\n");}
                | expression SUBTRACTION expression {printf("binary_expression -> expression SUBTRACTION expression\n");}
                | expression MULTIPLICATION expression {printf("binary_expression -> expression MULTIPLICATION expression\n");}
                | expression DIVISION expression {printf("binary_expression -> expression DIVISION expression\n");}
                | expression MOD expression {printf("binary_expression -> expression MOD expression\n");}
                | expression EQUALS_TO expression {printf("binary_expression -> expression EQUALS_TO expression\n");}
                | expression NOT_EQUALS_TO expression {printf("binary_expression -> expression NOT_EQUALS_TO expression\n");}
                | expression LESS_THAN expression {printf("binary_expression -> expression LESS_THAN expression\n");}
                | expression LESS_THAN_OR_EQUAL_TO expression {printf("binary_expression -> expression LESS_THAN_OR_EQUAL_TO expression\n");}
                | expression GREATER_THAN expression {printf("binary_expression -> expression GREATER_THAN expression\n");}
                | expression GREATER_THAN_OR_EQUAL_TO expression {printf("binary_expression -> expression GREATER_THAN_OR_EQUAL_TO expression\n");}
                ;

args: %empty {printf("args -> epsilon\n");}
    | arg repeat_args {printf("args -> arg repeat_args\n");}

repeat_args: %empty {printf("repeat_args -> epsilon\n");}
        | expression {printf("argument -> expression\n");}
        | COMMA arg repeat_args {printf("repeat_args -> COMMA arg repeat_args\n");}

arg: expression {printf("argument -> expression\n");}
        ;

return_statement: RETURN expression END_STATEMENT {printf("return_statement -> RETURN expression END_STATEMENT\n");}


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