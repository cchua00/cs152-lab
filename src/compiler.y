%{
#include <iostream> 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <string>
#include <iostream>
#include <sstream> 
#include <vector>
#include "y.tab.h"
extern FILE* yyin;
extern int line_number;
extern int column_number; 
extern int yylex(void);

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
};

struct Symbol {
  std::string name;
  Type type;
};

struct Function {
  std::string name;
  Type returnType;
  std::vector<Symbol> declarations;
};

std::vector <Function> symbol_table;

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


bool find(std::string &value, Type t) {
  Function *f = get_function();
  for(int i=0; i < f->declarations.size(); i++) {
    Symbol *s = &f->declarations[i];
    if (s->name == value && s->type == t) {
      return true;
    }
  }
  return false;
}

void add_function_to_symbol_table(std::string &value, Type returnType) {
  Function f; 
  f.name = value;
  f.returnType = returnType;
  symbol_table.push_back(f);
}

void add_variable_to_symbol_table(std::string &value, Type t) {
  Symbol s;
  s.name = value;
  s.type = t;
  Function *f = get_function();
  f->declarations.push_back(s);
}

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

std::string create_label(){
        static int num = 1;
        std::ostringstream ss;
        ss << num;
        std::string value = "_label" + ss.str();
        num += 1;
        return value;
}

std::string create_temp() {
        static int num = 0;
        std::ostringstream ss;
        ss << num;
        std::string value = "_temp" + ss.str();
        num += 1;
        return value;
}

std::string decl_temp_code(std::string &temp){
        return std::string(". ") + temp + std::string("\n");
}

bool findFunction(std::string& name, Type returnType)
{
        for (int i = 0; i < symbol_table.size(); i++)
        {
                if (symbol_table[i].name == name && symbol_table[i].returnType == returnType) return true;
        }
        return false;
}

%}

%union {

        char *op_val;
        struct CodeNode *node;
}

%error-verbose
%start prog_start

%token WRITE READ WHILE BREAK CONTINUE IF ELSE INSERT EXTRACT RETURN INTEGER
%token ADDITION SUBTRACTION MULTIPLICATION DIVISION MOD ASSIGN
%token EQUALS_TO LESS_THAN GREATER_THAN LESS_THAN_OR_EQUAL_TO GREATER_THAN_OR_EQUAL_TO NOT OPEN_PARAMETER
%token CLOSE_PARAMETER OPEN_SCOPE CLOSE_SCOPE OPEN_BRACKET CLOSE_BRACKET END_STATEMENT COMMA ENDL
%type <node> functions
%type <node> function
%type <node> function_call
%type <node> statements
%type <node> statement
%type <node> assign_statement
%type <node> else_statement
%type <node> print_statement
%type <node> input_statement
%type <node> if_statement
%type <node> while_statement
%type <node> break_statement
%type <node> continue_statement
%type <node> return_statement
%type <node> int_declaration
%type <node> array_declaration
%type <node> assign_int
%type <node> assign_array
%type <node> add_expression
%type <node> arg
%type <node> args
%token <op_val> ALPHA
%token <op_val> DIGIT
%type <op_val> function_identifier add_to_symbol_table
%type <node> mult_expression 
%type <node> expression 
%type <node> binary_expression 
%type <node> base_expression  
%type <node> param
%type <node> params
%type <node> repeat_args
%type <node> return_expression
%%

prog_start: 
        %empty /* epsilon */ 
        {} 
        | functions 
        {
                std::string mainCheck = "main";
                if (!findFunction(mainCheck, Integer))
                {
                        std::string errorMsg = "File must define a main function returning int.";
                        yyerror(errorMsg.c_str());
                }
                CodeNode *node = $1;
                std::string code = node->code;
                printf("%s\n", code.c_str());      
        }
        ;

functions: 
        function 
        {
                CodeNode *func = $1;
                std::string code = func->code;
                CodeNode *node = new CodeNode;
                node->code = code;
                $$ = node;
        }
        | function functions 
        {
                CodeNode *func = $1;
                CodeNode *funcs = $2;
                std::string code = func->code + std::string("\n") + funcs->code;
                CodeNode *node = new CodeNode;
                node->code = code;
                $$ = node;
        }
        ;

function: 
        INTEGER add_to_symbol_table OPEN_PARAMETER args CLOSE_PARAMETER OPEN_SCOPE statements CLOSE_SCOPE 
        {
                CodeNode *node = new CodeNode;

                char *c = $2;
                std::string function_identifier(c);

                CodeNode *arg = $4;
                node->code = function_identifier + arg->code;

                CodeNode *body = $7;
                node->code += body->code;
                if (node->code.find("ret") == std::string::npos && get_function()->returnType == Integer)
                {
                        std::string funcName = get_function()->name;
                        if(funcName != "main") {
                                std::string errorMsg = "no return statement in function";
                                yyerror(errorMsg.c_str());
                        }
                }
                node->code += "endfunc\n";
                $$ = node; 
        }
	;

add_to_symbol_table: function_identifier {
                char *c = $1;
                std::string function_identifier(c);
                std::string functionName = function_identifier.substr(5, function_identifier.size() - 6);

                if (findFunction(functionName, Integer))
                {
                                std::string errorMsg = "Cannot have two functions with the same name \"" + functionName + "\"";
                                yyerror(errorMsg.c_str());
                }
                
                add_function_to_symbol_table(functionName, Integer);
                $$ = $1;
        };

function_identifier: ALPHA {
                std::string func_name = $1;
                std::string functionDeclaration = "func " + func_name + "\n";
                int strLen = functionDeclaration.size();
                char *c = new char[strLen + 1];
                std::copy(functionDeclaration.begin(), functionDeclaration.end(), c);
                c[strLen] = '\0';

                $$ = c;
        };

statements: 
        statement statements 
        {
                CodeNode *stmt1 = $1;
                CodeNode *stmt2 = $2;
                CodeNode *node = new CodeNode;
                node->code = stmt1->code + stmt2->code;
                $$ = node; 
        }
        | %empty 
        {
                CodeNode *node = new CodeNode;
                $$ = node;
        }
        ;

statement: 
        int_declaration 
        {
                $$ = $1;
        }
        | array_declaration 
        {
                $$ = $1;
        }
        | print_statement 
        {
                $$ = $1;
        }
        | input_statement 
        {
                $$ = $1;
        }
        | if_statement 
        {
                $$ = $1;
        }
        | while_statement 
        {
                $$ = $1;
        }
        | break_statement 
        {
                $$ = $1;
        }
        | continue_statement 
        {
                $$ = $1;
        }
        | function_call 
        {
                $$ = $1;
        }
        | return_statement 
        {
                $$ = $1;
        }
        | assign_int 
        {
                $$ = $1;
        }
        | assign_array 
        {
                $$ = $1;
        }
        ;

int_declaration: 
        INTEGER ALPHA assign_statement END_STATEMENT 
        {
                CodeNode *assign_statement = $3;
                std::string value = $2;
                if (find(value, Integer))
                {
                        std::string funcName = get_function()->name;
                        std::string errorMsg = "\"" + value + "\" is being redeclared";
                        
                        yyerror(errorMsg.c_str());
                }
                else {
                        add_variable_to_symbol_table(value, Integer);
                }
                std::string code = std::string(". ") + value + std::string("\n");
                CodeNode *node = new CodeNode;
                node->code += code;
                node->code += assign_statement->code;
                node->code = code;
                $$ = node;
        }
        ;

array_declaration: 
        INTEGER ALPHA OPEN_BRACKET DIGIT CLOSE_BRACKET assign_statement END_STATEMENT 
        {
                CodeNode *node = new CodeNode;
                std::string symbol = $4;
                std::string array_name = $2;
                int index = 0;
                std::stringstream ss($4);
                ss >> index;
                if (index < 1) {
                        std::string funcName = get_function()->name;
                        std::string error_message = "index must be a positive whole number.";
                        yyerror(error_message.c_str());    
                }
                
                if (find(array_name, Array) || find(array_name, Integer)) {
                        std::string funcName = get_function()->name;
                        std::string error_message = array_name + " already exists in the symbol table.";
                        yyerror(error_message.c_str());
                }
                else {
                        add_variable_to_symbol_table(array_name, Array);
                }
                node->code = ".[] " + array_name + ", " + symbol + "\n";
                $$ = node;
        }
	;

assign_statement: 
        ASSIGN add_expression 
        {	
		CodeNode *node = new CodeNode;
                CodeNode *add_expression = $2;

                std::string code = std::string("=");
                code += add_expression->code;
                node->code = code;    
                $$ = node; 
        }
        | %empty 
        {
                CodeNode *node = new CodeNode;
                $$ = node;
        }
        ;

print_statement: 
        WRITE EXTRACT binary_expression END_STATEMENT 
        {
		            CodeNode *node = new CodeNode; 
		            CodeNode *binary_expression = $3; 
		            std::string code = binary_expression->code + std::string(".> ") + binary_expression->name + std::string("\n"); 
                node->code = code;   		
		            $$ = node; 
        }
        | 
        WRITE EXTRACT binary_expression EXTRACT ENDL END_STATEMENT 
        {
		            CodeNode *node = new CodeNode; 
		            CodeNode *binary_expression = $3;   
		            std::string code = binary_expression->code + std::string(".> ") + binary_expression->name + std::string("\n"); 
                node->code = code;
		            $$ = node;
        }
        ;

input_statement: 
        READ INSERT ALPHA END_STATEMENT 
        {
                CodeNode* node = new CodeNode; 
                std::string value = $3; 
                std::string code = std::string(".< ") + value + std::string("\n"); 
                node->code = code; 
                $$ = node;        
        }
        ;

if_statement: 
        IF expression OPEN_SCOPE statements CLOSE_SCOPE else_statement 
        {
                CodeNode *expr = $2; //cond
                CodeNode *stmts = $4; //else
                CodeNode *else_statement = $6; //ifpart... need to rework so the code here is in else_statement rule
                CodeNode *node = new CodeNode; 
                
                node->code = expr->code;
                std::string label_start = create_label();
                node->code += std::string("?:= ") + label_start + std::string(", ") + expr->name + std::string("\n");
                node->code += else_statement->code;
                //node->code += std::string("?:= ") + label_start + ", " + expr->name + std::string("\n");
                
                std::string label_end = create_label(); 
                node->code += std::string(":= ") + label_end + std::string("\n");
                node->code += std::string(": ") + label_start + std::string("\n");
                node->code += stmts->code;
                node->code += std::string(": ") + label_end + std::string("\n");
                $$ = node;         
        }
        ;

else_statement: 
        ELSE OPEN_SCOPE statements CLOSE_SCOPE 
        {
		CodeNode* node = new CodeNode; 
		CodeNode* stmts = $3;
		//std::string code = std::string("else\n"); 

		std::string code = stmts->code; //this is being pushed to if_statement
		node->code = code; 
		$$ = node; 
        }
        | %empty 
        {
                CodeNode *node = new CodeNode;
                $$ = node;
        }
        ;

while_statement: 
        WHILE OPEN_PARAMETER binary_expression CLOSE_PARAMETER OPEN_SCOPE statements CLOSE_SCOPE 
        {
		/*CodeNode* statements = $6; 	
                CodeNode* binary_expression = $3;
                code += std::string(":= beginloop\n"); 
                code += std::strig(".temp\n"); 
                code += std::string("< temp, ") + std::string("\n"); 
                code += std::string("?:= loopbody, temp\n"); 
                code += std::string(":= endloop\n"); 
                code += std::string(": loopbody\n"); 
                code += statements->code; 
                code += std::string(":= beginloop\n"); 
                code += std::string(": endloop\n"); 
                CodeNode* node = new CodeNode; 
                node->code = code; 
                $$ = node;*/
        }
        ;

break_statement: 
        BREAK END_STATEMENT 
        { 	
		CodeNode* node = new CodeNode; 
		node->code = std::string(":= endloop\n");  
		$$ = node; 		
        }
        ;  

continue_statement: 
        CONTINUE END_STATEMENT 
        {
		CodeNode* node = new CodeNode; 
		node->code = std::string(":= beginloop\n"); 
		$$ = node; 
        }
        ;

expression: 
        OPEN_PARAMETER binary_expression CLOSE_PARAMETER 
        {
		CodeNode* binary_expression = $2; 
		CodeNode* node = new CodeNode; 
		node->code = binary_expression->code; 
                node->name = binary_expression->name; 
		$$ = node; 
        }
        | DIGIT 
        {
                CodeNode* node = new CodeNode;
                std::string digit = $1;
                node->name = digit;
                $$ = node;
        }    
        | ALPHA 
        {
                CodeNode *node = new CodeNode;
                std::string value($1);
                if (!find(value, Integer))
                {
                        std::string funcName = get_function()->name;
                        std::string errorMsg = "use of unknown variable \"" + value + "\"" + " before declaration.";
                        
                        yyerror(errorMsg.c_str());
                }
                node->name = value;
                $$ = node;
        }
        | ALPHA OPEN_BRACKET DIGIT CLOSE_BRACKET 
        {
                CodeNode *node = new CodeNode;
                std::string symbol($3);

                if (!find(symbol, Array))
                {
                        std::string funcName = get_function()->name;
                        std::string errorMsg = "use of unknown variable \"" + symbol + "\"" + " before declaration.";
                        
                        yyerror(errorMsg.c_str());
                }

                std::string temp = create_temp();
                node->name = temp;
                std::string declareTemp = decl_temp_code(temp); 
                std::string array_name = $1;
                node->code = declareTemp + "=[] " + temp + ", " + array_name + ", " + symbol + "\n";
                $$ = node;
        }
        | function_call 
        {
                $$ = $1;
        }
        ;

binary_expression: 
        add_expression 
        {
                CodeNode *add_expression = $1;
                CodeNode *node = new CodeNode;
                node->code = add_expression->code;
                node->name = add_expression->name;
                $$ = node;
        }
        | binary_expression EQUALS_TO add_expression 
        {
                std::string temp = create_temp();
                CodeNode* node = new CodeNode;
                node->code = $1->code + $3->code + decl_temp_code(temp);
                node->code += std::string("== ") + temp + std::string(", ") + $1->name + std::string(", ") + $3->name + std::string("\n");
                node->name = temp;
                $$ = node;
        
        }
        | binary_expression NOT add_expression 
        {
                std::string temp = create_temp();
                CodeNode *node = new CodeNode;
                node->code = $1->code + $3->code + decl_temp_code(temp);
                node->code += std::string("!= ") + temp + std::string(", ") + $1->name + std::string(", ") + $3->name + std::string("\n");
                node->name = temp;
                $$ = node;
        }
        | binary_expression LESS_THAN add_expression 
        {
                std::string temp = create_temp();
                CodeNode *node = new CodeNode;
                node->code = $1->code + $3->code + decl_temp_code(temp);
                node->code += std::string("< ") + temp + std::string(", ") + $1->name + std::string(", ") + $3->name + std::string("\n");
                node->name = temp;
                $$ = node;
        }
        | binary_expression LESS_THAN_OR_EQUAL_TO add_expression 
        {
                std::string temp = create_temp();
                CodeNode *node = new CodeNode;
                node->code = $1->code + $3->code + decl_temp_code(temp);
                node->code += std::string("<= ") + temp + std::string(", ") + $1->name + std::string(", ") + $3->name + std::string("\n");
                node->name = temp;
                $$ = node;
        }
        | binary_expression GREATER_THAN add_expression 
        {
                std::string temp = create_temp();
                CodeNode *node = new CodeNode;
                node->code = $1->code + $3->code + decl_temp_code(temp);
                node->code += std::string("> ") + temp + std::string(", ") + $1->name + std::string(", ") + $3->name + std::string("\n");
                node->name = temp;
                $$ = node;
        }
        | binary_expression GREATER_THAN_OR_EQUAL_TO add_expression 
        {
                std::string temp = create_temp();
                CodeNode *node = new CodeNode;
                node->code = $1->code + $3->code + decl_temp_code(temp);
                node->code += std::string(">= ") + temp + std::string(", ") + $1->name + std::string(", ") + $3->name + std::string("\n");
                node->name = temp;
                $$ = node;
        }
        ;

add_expression: 
        mult_expression 
        {
                CodeNode *mult_expression = $1;
                CodeNode *node = new CodeNode;
                node->code = mult_expression->code;
                node->name = mult_expression->name;
                $$ = node;
        }
        | add_expression ADDITION mult_expression 
        {
                std::string temp = create_temp();
                CodeNode *node = new CodeNode;
                node->code = $1->code + $3->code;
                node->code += decl_temp_code(temp) + std::string("+ ") + temp + std::string(", ") + $1->name + std::string(", ") + $3->name + std::string("\n");
                node->name = temp;
                $$ = node;
        }
        | add_expression SUBTRACTION mult_expression 
        {
                std::string temp = create_temp();
                CodeNode *node = new CodeNode;
                node->code = $1->code + $3->code;
                node->code += decl_temp_code(temp) + std::string("- ") + temp + std::string(", ") + $1->name + std::string(", ") + $3->name + std::string("\n");
                node->name = temp;
                $$ = node;
        }
        ;

mult_expression: 
        base_expression 
        {
                CodeNode *base_expression = $1;
                CodeNode *node = new CodeNode;
                node->code = base_expression->code;
                node->name = base_expression->name;
                $$ = node;
        }
        | mult_expression MULTIPLICATION base_expression 
        {
                std::string temp = create_temp();
                CodeNode *node = new CodeNode;
                node->code = $1->code + $3->code;
                node->code += decl_temp_code(temp) + std::string("* ") + temp + std::string(", ") + $1->name + std::string(", ") + $3->name + std::string("\n");
                node->name = temp;
                $$ = node;
        }
        | mult_expression DIVISION base_expression 
        {
                std::string temp = create_temp();
                CodeNode *node = new CodeNode;
                node->code = $1->code + $3->code ;
                node->code += decl_temp_code(temp) + std::string("/ ") + temp + std::string(", ") + $1->name + std::string(", ") + $3->name + std::string("\n");
                node->name = temp;
                $$ = node;
        }
        | mult_expression MOD base_expression 
        {
                std::string temp = create_temp();
                CodeNode *node = new CodeNode;
                node->code = $1->code + $3->code;
                node->code += decl_temp_code(temp) + std::string("% ") + temp + std::string(", ") + $1->name + std::string(", ") + $3->name + std::string("\n");
                node->name = temp;
                $$ = node;
        }
        ;

//alex does below this
base_expression: 
        expression
        {
	        CodeNode* expression = $1;
                CodeNode* node = new CodeNode;
                node->code = expression->code;
                node->name = expression->name;
                $$ = node;
        }
        ;

assign_int: 
        ALPHA ASSIGN add_expression END_STATEMENT 
        {
                CodeNode *node = new CodeNode;
                CodeNode *value = $3;
                std::string int_name = $1;
                node->code = value->code + "= " + int_name + ", " + value->name + "\n";
                $$ = node;

                if (find(int_name, Array))
                {
                        std::string funcName = get_function()->name;
                        std::string errorMsg = "use of array variable \"" + int_name + "\"" + " without specifying index.";

                        yyerror(errorMsg.c_str());
                }
                else if (!find(int_name, Integer)) {
                        std::string funcName = get_function()->name;
                        std::string error_message = int_name + " was used without declaration.";
                        yyerror(error_message.c_str());
                }
        }       
        ;

assign_array: 
        ALPHA OPEN_BRACKET DIGIT CLOSE_BRACKET ASSIGN add_expression END_STATEMENT 
        {
                std::string array_name($1);
                if (find(array_name, Integer))
                {
                        std::string funcName = get_function()->name;
                        std::string error_message = "In function " + funcName + ", use of integer variable " + array_name + " as array (specifying index for integer variable).";
                        yyerror(error_message.c_str());
                }
                else if (!find(array_name, Array)) {
                        std::string funcName = get_function()->name;
                        std::string error_message = "In function " + funcName + ", array " + array_name + " does not exist in the symbol table.";
                        yyerror(error_message.c_str());
                }
                std::string temp = create_temp();
                std::string temp2 = decl_temp_code(temp);
                CodeNode* node = new CodeNode;
                std::string symbol($1);
                std::string index($3);
                CodeNode* src = $6;
                node->name = temp;
                node->code = src->code + temp2 + "[]= " + array_name + ", " + index + ", " + src->name + "\n";  
                $$ = node;
        }
        ;

function_call: 
        ALPHA OPEN_PARAMETER param CLOSE_PARAMETER 
        {
                std::string temp = create_temp();
                CodeNode *node = new CodeNode;
                CodeNode *param = $3;
                Type t = Integer;
                std::string value = $1;

                if(!findFunction(value, t))
                {
                        std::string error_message = "Use of undefined function " + value;
                        yyerror(error_message.c_str());
                }

                node->code = param->code + decl_temp_code(temp);
                node->code += std::string("call ") + value + std::string(", ") + temp + std::string("\n");
                node->name = temp;
                $$ = node;
        }

param: 
        add_expression params 
        {
                CodeNode *node = new CodeNode;
                CodeNode *param = $1;
                CodeNode *params = $2;
                node->code = std::string("param ") + param->name + std::string("\n");
                node->code += params->code;
                $$ = node;
                
        }
        | %empty 
        {
                CodeNode *node = new CodeNode;
                $$ = node;
        }
        ;

params: 
        COMMA add_expression params 
        {
                CodeNode *node = new CodeNode;
                CodeNode *params = $2;
                node->code = params->code;
                node->code += std::string("param ") + params->name + std::string("\n");
                $$ = node;
        }
        | %empty 
        {
                CodeNode *node = new CodeNode;
                $$ = node;
        }
        ;

args: 
        arg repeat_args 
        {
                CodeNode *node = new CodeNode;
                CodeNode *arg = $1;
                CodeNode *args = $2;
                std::string code = arg->code + args->code;
                std::string variableAssignments = "";

                std::stringstream ss(code);
                std::ostringstream intConverter;
                std::string currLine;
                int currentParam = 0;
                
                while (std::getline(ss, currLine))
                {
                        std::string currVar;
                        if (currLine.substr(0, 2) == ". ")
                        {
                                currVar = currLine.substr(2);
                        }
                        intConverter << currentParam++;
                        variableAssignments += "= " + currVar + ", " + "$" + intConverter.str() + "\n";
                        intConverter.str("");
                        intConverter.clear();
                }
                
                node->code = code + variableAssignments;
                $$ = node;
        } 
        | %empty 
        {
                CodeNode *node = new CodeNode;
                $$ = node;
        }
        ;

repeat_args: 
        COMMA arg repeat_args 
        {
                CodeNode *node = $2;
                $$ = node;
        }
        | %empty 
        {
                CodeNode *node = new CodeNode;
                $$ = node;
        }
        ;

arg: 
        INTEGER ALPHA 
        {
                std::string value = $2;
                Type t = Integer;
                if (find(value, Integer))
                {
                        std::string errorMsg = "symbol " + value + " is multiply-defined.";
                        
                        yyerror(errorMsg.c_str());
                        
                }
                add_variable_to_symbol_table(value, t);

                std::string code = std::string(". ") + value + std::string("\n");
                CodeNode *node = new CodeNode;
                node->code = code;
                $$ = node;
        }
        ;

return_statement: 
        RETURN return_expression END_STATEMENT 
        {
                CodeNode *node = new CodeNode;
                CodeNode *ret = $2;
                node->code = ret->code + std::string("ret ") + ret->name + std::string("\n");
                $$ = node;
        }
        ;

return_expression: 
        add_expression 
        {
                $$ = $1;
        }
        ;
%%

int main(int argc, char** argv) {
	if (argc >= 2) {
		yyin = fopen(argv[1], "r");
		if (yyin == NULL)
			yyin = stdin;
	}
	else {
		yyin = stdin;
	}
	yyparse();

        return 1;
}
