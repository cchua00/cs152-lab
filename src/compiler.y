%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <vector>
#include "y.tab.h"
extern FILE* yyin;
extern int line_number;
extern int column_number; 

void yyerror(const char * s) {
    printf("Error: On line %d, column %d: %s \n", line_number, column_number, s);
}

char *identToken;
int numberToken;
int count_names = 0;

enum Type { Integer, Array };

struct CodeNode {
        std::string code;
        std::string name;
}

struct Symbol {
  std::string name;
  Type type;
};

struct Function {
  std::string name;
  std::vector<Symbol> declarations;
};

std::vector <Function> symbol_table;

// remember that Bison is a bottom up parser: that it parses leaf nodes first before
// parsing the parent nodes. So control flow begins at the leaf grammar nodes
// and propagates up to the parents.
Function *get_function() {
  int last = symbol_table.size()-1;
  if (last < 0) {
    printf("***Error. Attempt to call get_function with an empty symbol table\n");
    printf("Create a 'Function' object using 'add_function_to_symbol_table' before\n");
    printf("calling 'find' or 'add_variable_to_symbol_table'");
    exit(1);
  }
  return &symbol_table[last];
}

// find a particular variable using the symbol table.
// grab the most recent function, and linear search to
// find the symbol you are looking for.
// you may want to extend "find" to handle different types of "Integer" vs "Array"
bool find(std::string &value) {
  Function *f = get_function();
  for(int i=0; i < f->declarations.size(); i++) {
    Symbol *s = &f->declarations[i];
    if (s->name == value) {
      return true;
    }
  }
  return false;
}

// when you see a function declaration inside the grammar, add
// the function name to the symbol table
void add_function_to_symbol_table(std::string &value) {
  Function f; 
  f.name = value; 
  symbol_table.push_back(f);
}

// when you see a symbol declaration inside the grammar, add
// the symbol name as well as some type information to the symbol table
void add_variable_to_symbol_table(std::string &value, Type t) {
  Symbol s;
  s.name = value;
  s.type = t;
  Function *f = get_function();
  f->declarations.push_back(s);
}

// a function to print out the symbol table to the screen
// largely for debugging purposes.
void print_symbol_table(void) {
  printf("symbol table:\n");
  printf("--------------------\n");
  for(int i=0; i<symbol_table.size(); i++) {
    printf("function: %s\n", symbol_table[i].name.c_str());
    for(int j=0; j<symbol_table[i].declarations.size(); j++) {
      printf("  locals: %s\n", symbol_table[i].declarations[j].name.c_str());
    }
  }
  printf("--------------------\n");
}

%}

%union {
        char *op_val;
        struct CodeNode *node;
}


%error-verbose
%start prog_start

%token WRITE READ WHILE BREAK CONTINUE IF ELSE INSERT EXTRACT RETURN INTEGER
%token ALPHA DIGIT
%token ADDITION SUBTRACTION MULTIPLICATION DIVISION MOD ASSIGN
%token EQUALS_TO LESS_THAN GREATER_THAN LESS_THAN_OR_EQUAL_TO GREATER_THAN_OR_EQUAL_TO NOT OPEN_PARAMETER
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
        add_expression 
        {
        
        }
        | binary_expression EQUALS_TO add_expression 
        {
                $$ = "==";
        }
        | binary_expression NOT add_expression 
        {
                $$ = "!=";
        }
        | binary_expression LESS_THAN add_expression 
        {
                $$ = "<";
        }
        | binary_expression LESS_THAN_OR_EQUAL_TO add_expression 
        {
                $$ = "<=";
        }
        | binary_expression GREATER_THAN add_expression 
        {
                $$ = ">";
        }
        | binary_expression GREATER_THAN_OR_EQUAL_TO add_expression 
        {
                $$ = ">=";
        }
        ;

add_expression: 
        mult_expression 
        {
                $$ = $1;
        }
        | add_expression ADDITION mult_expression 
        {
                std::string temp = create_temp();
                CodeNode *node = new CodeNode;
                node->code = $1->code + $3->code + decl_temp_code(temp);
                node->code = std::string("+ ") + temp + std::string(", ") + $1->name + std::string(", ") + $3->name + std::string("\n");
                node->name = temp;
                $$ = node;
        }
        | add_expression SUBTRACTION mult_expression 
        {
                std::string temp = create_temp();
                CodeNode *node = new CodeNode;
                node->code = $1->code + $3->code + decl_temp_code(temp);
                node->code = std::string("- ") + temp + std::string(", ") + $1->name + std::string(", ") + $3->name + std::string("\n");
                node->name = temp;
                $$ = node;
        }
        ;

mult_expression: 
        base_expression 
        {
                $$ = $1;
        }
        | mult_expression MULTIPLICATION base_expression 
        {
                std::string temp = create_temp();
                CodeNode *node = new CodeNode;
                node->code = $1->code + $3->code + decl_temp_code(temp);
                node->code = std::string("* ") + temp + std::string(", ") + $1->name + std::string(", ") + $3->name + std::string("\n");
                node->name = temp;
                $$ = node;
        }
        | mult_expression DIVISION base_expression 
        {
                std::string temp = create_temp();
                CodeNode *node = new CodeNode;
                node->code = $1->code + $3->code + decl_temp_code(temp);
                node->code = std::string("/ ") + temp + std::string(", ") + $1->name + std::string(", ") + $3->name + std::string("\n");
                node->name = temp;
                $$ = node;
        }
        | mult_expression MOD base_expression 
        {
                std::string temp = create_temp();
                CodeNode *node = new CodeNode;
                node->code = $1->code + $3->code + decl_temp_code(temp);
                node->code = std::string("% ") + temp + std::string(", ") + $1->name + std::string(", ") + $3->name + std::string("\n");
                node->name = temp;
                $$ = node;
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
        | %empty 
        {
        
        }
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

bool has_main(){
        bool TF = false;
        for (int i = 0; i<symbol_table.size(); i++){
                Function *f = &symbol_table[i];
                if (f->name == "main")
                        TF = true;
        }
        return TF;
}

std::string create_temp(){
        static int num = 0;
        std::string value = "_temp" + std::to_string(num);
        num += 1;
        return value;
}

std::string decl_temp_code(std::string &temp){
        return std::string(". ") + temp + std::string("\n");
}