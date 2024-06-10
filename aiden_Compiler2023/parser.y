%{
#include "codegen.hpp"
#include "lex.yy.cpp"
#include <sstream>
#define Trace(t)        printf(t)
void yyerror(string s);
symboltables symtab;
int param_num = 0;
string filename;
string className;
ofstream output;
%}

/* tokens */
%token ARRAY BEGIN_ BOOL CHAR CONST DECREASING DEFAULT DO ELSE END EXIT FALSE FOR FUNCTION GET IF INT LOOP OF PUT PROCEDURE REAL RESULT RETURN SKIP STRING THEN TRUE VAR WHEN
 
%token ASSIGN AND OR NOT NOT_EQU LE GE MOD

%union {
  int ival;
  float fval;
  string *sval;
  type var_type;
  Symbol *symval;
}

%token <sval> IDENTIFIER
%token <ival> INT_NUM
%token <fval> REAL_NUM
%token <sval> STRING_CONSTANTS

%type <symval> constant_exp expression function_procedure array_reference number
%type <var_type> type

/* precedence */
%nonassoc OR
%left AND
%left NOT
%left '<' LE '=' GE '>' NOT_EQU
%left '+' '-'
%left '*' '/' MOD
%nonassoc UMINUS
%precedence IDENTIFIER
%precedence ASSIGN '(' '['

%%
program:    
        {
                G_init();
        }
        declarations 
        {
                G_main();
        }
        statements
        {
                G_Return();
                G_main_end();
                G_end();
        }
        ;
statements:     statements statement
        |
        ;
statement:  block
        |   simple
        |   condition
        |   loop
        ;
declarations:   declarations declaration_function
        |
        ;
declaration_function:   declaration
        |   function
        |   procedure
        ;
declaration:    constants
        |   variable
        |   array
        ;
constants:  CONST IDENTIFIER type ASSIGN constant_exp
        {
                /* check if the identifier is already in the symbol table */
                if(symtab.lookup(*($2)) != NULL)
                        yyerror("const redefine");
                
                /* check if the type of the identifier is the same as the type of the constant */
                if ($3 != $5->S_type)
                        printf("Warning: type mismatch\n");

                $5->init = true;
                /* insert the identifier into the symbol table */
                symtab.insert(*($2), *$5);
                
        }
        |   CONST IDENTIFIER ASSIGN constant_exp
        {
                /* check if the identifier is already in the symbol table */
                if(symtab.lookup(*($2)) != NULL)
                        printf("ERROR");
                
                $4->init = true;
                /* insert the identifier into the symbol table */
                symtab.insert(*($2), *$4);
        }
        ;
type:       ':' INT
        {
                $$ = type::INT_TYPE;
        }
        |   ':' REAL
        {
                $$ = type::REAL_TYPE;
        }
        |   ':' BOOL
        {
                $$ = type::BOOL_TYPE;
        }
        |   ':' STRING
        {
                $$ = type::STRING_TYPE;
        }
        ;
constant_exp:   INT_NUM
        {
                $$ = intConst($1);
        }
        |   REAL_NUM
        {
                $$ = realConst($1);
        }       
        |   STRING_CONSTANTS
        {
                $$ = stringConst($1);
        }
        |   TRUE
        {
                $$ = boolConst(true);
        }
        |   FALSE
        {
                $$ = boolConst(false);
        }
        ;
variable:   VAR IDENTIFIER type ASSIGN constant_exp
        {
                /* check if the identifier is already in the symbol table */
                if(symtab.lookup(*($2)) != NULL)
                        yyerror("variable redefine");
                
                /* check if the type of the identifier is the same as the type of the constant */
                if ($3 != $5->S_type)
                        printf("Warning: type mismatch\n");

                $5->init = true;
                $5->S_flag = flag::VARIABLE;
                /* insert the identifier into the symbol table */
                symtab.insert(*($2), *$5);
                int index = symtab.get_index(*($2));
                if(index == -1)
                        G_global_Var(*$2, $5->S_data.int_data);
                else
                        G_local_Var(index, $5->S_data.int_data);
        }
        |   VAR IDENTIFIER type
        {
                /* check if the identifier is already in the symbol table */
                if(symtab.lookup(*($2)) != NULL)
                        yyerror("variable redefine");
                
                Symbol s;
                s.init = false;
                s.S_type = $3;
                s.S_flag = flag::VARIABLE;
                symtab.insert(*($2), s);
                
                int index = symtab.get_index(*($2));
                if(index == -1)
                        G_global_Var(*$2);
                
        }
        |   VAR IDENTIFIER ASSIGN constant_exp
        {
                /* check if the identifier is already in the symbol table */
                if(symtab.lookup(*($2)) != NULL)
                        yyerror("variable redefine");
                
                $4->init = true;
                $4->S_flag = flag::VARIABLE;
                /* insert the identifier into the symbol table */
                symtab.insert(*($2), *$4);
                int index = symtab.get_index(*($2));
                if(index == -1)
                        G_global_Var(*$2, $4->S_data.int_data);
                else
                        G_local_Var(index, $4->S_data.int_data);
        }
        ;
array:  ARRAY IDENTIFIER ':' ARRAY number '.' '.' number OF type
        {
                /* check if the identifier is already in the symbol table */
                if(symtab.global_lookup(*($2)) != NULL)
                        yyerror("array redefine");
                
                if($5->S_flag!=flag::CONSTANT || $8->S_flag!=flag::CONSTANT)
                        yyerror("array index must be constant");

                if($5->S_type != type::INT_TYPE || $8->S_type != type::INT_TYPE)
                        yyerror("array index must be integer");

                Symbol s;
                s.init = true;
                s.S_flag = flag::ARRAY_FLAG;
                s.S_type = $10;
                symtab.insert(*($2), s);
        }
        ;
number:    INT_NUM
        {
                $$ = intConst($1);
        }
        |   IDENTIFIER
        {
                /* check if the identifier is already in the symbol table */
                if(symtab.global_lookup(*($1)) == NULL)
                        yyerror("identifier not found");
                
                Symbol *s = symtab.global_lookup(*($1));
                
                $$ = s;
        }
        ;
function:  FUNCTION IDENTIFIER 
        {
                /* check if the identifier is already in the symbol table */
                if(symtab.lookup(*($2)) != NULL)
                        yyerror("function redefine");
                
                Symbol s;
                s.init = true;
                s.S_flag = flag::FUNC;
                symtab.insert(*($2), s);
                symtab.push();
                param_num = 0;
        }
        '(' parameters_block ')' type 
        {
                Symbol *temp = symtab.global_lookup(*($2));
                temp->param_num = param_num;
                G_method_Start(*symtab.global_lookup(*($2)));
        }
        function_bodys END IDENTIFIER
        {
                cout<<"<-----------------------local variable------------------->"<<endl;
                symtab.tables.back().dump();
                cout<<"<-----------------------local variable end--------------->"<<endl;
                symtab.pop();
                symtab.tables.back().table.back().S_type = $7;
                symtab.tables.back().table.back().param_num = param_num;
                param_num = 0;
                if (*$2 != *$11)
                        yyerror("function declaration error");
                G_main_end();
        }
        ;
procedure:  PROCEDURE IDENTIFIER
        {
                /* check if the identifier is already in the symbol table */
                if(symtab.lookup(*($2)) != NULL)
                        yyerror("procedure redefine");
                
                Symbol s;
                s.init = true;
                s.S_flag = flag::FUNC;
                s.S_type = type::NONE;
                symtab.insert(*($2), s);
                symtab.push();
                param_num = 0;
        }
        '(' parameters_block ')' 
        {
                Symbol *temp = symtab.global_lookup(*($2));
                temp->param_num = param_num;
                G_method_Start(*symtab.global_lookup(*($2)));
        }
        function_bodys END IDENTIFIER
        {
                cout<<"<-----------------------local variable------------------->"<<endl;
                symtab.tables.back().dump();
                cout<<"<-----------------------local variable end--------------->"<<endl;
                symtab.pop();
                symtab.tables.back().table.back().param_num = param_num;
                param_num = 0;
                if (*$2 != *$10)
                        yyerror("function declaration error");
                G_main_end();
        }
        ;
function_bodys:  function_bodys function_body
        |
        ;
function_body:  declaration
        |   statement
        ;
parameters_block:  parameters
        |
        ;
parameters:     parameters ',' parameter
        |   parameter
        ;
parameter:  IDENTIFIER type
        {
                /* check if the identifier is already in the symbol table */
                if(symtab.lookup(*($1)) != NULL)
                        yyerror("variable redefine");
                
                param_num++;

                Symbol s;
                s.init = true;
                s.S_type = $2;
                s.S_flag = flag::VARIABLE;
                symtab.insert(*($1), s);
        }
        ;

block:      BEGIN_
        {
                int temp = symtab.tables.back().index;
                symtab.push();
                symtab.tables.back().index = temp;

        }
        function_bodys END
        {
                cout<<"<-----------------------local variable------------------->"<<endl;
                symtab.tables.back().dump();
                cout<<"<-----------------------local variable end--------------->"<<endl;
                int temp = symtab.tables.back().index;
                symtab.pop();
                symtab.tables.back().index = temp;
        }
        ;
simple:     IDENTIFIER ASSIGN expression
        {
                /* check if the identifier is in the symbol table */
                if(symtab.global_lookup(*($1)) == NULL)
                        yyerror("variable not defined");
                
                /* check if the identifier is a variable */
                if(symtab.global_lookup(*($1))->S_flag != flag::VARIABLE)
                        yyerror("not a variable");
                
                /* check if the type of the identifier is the same as the type of the expression */
                if (symtab.global_lookup(*($1))->S_type != $3->S_type)
                        yyerror("type mismatch");
                
                Symbol *s = symtab.global_lookup(*($1));
                s->init = true;
                s->S_data = $3->S_data;
                int index = symtab.get_index(*($1));
                if(index == -1)
                        G_set_global_Var(*$1);
                else
                        G_set_local_Var(index);
        }
        |   PUT 
        {
                G_put_Dec();
        }
        expression
        {
                G_put($3->S_type);
        }
        |   GET IDENTIFIER
        {
                /* check if the identifier is in the symbol table */
                if(symtab.global_lookup(*($2)) == NULL)
                        yyerror("variable not defined");
                
                /* check if the identifier is a variable */
                if(symtab.global_lookup(*($2))->S_flag != flag::VARIABLE)
                        yyerror("not a variable");
                
                Symbol *s = symtab.global_lookup(*($2));
                s->init = true;
        }
        |   RESULT expression
        {
                G_Result();
        }
        |   RETURN
        {
                G_Return();
        }
        |   EXIT when
        |   SKIP
        {
                G_skip();
        }
        | function_procedure
        ;
when:    WHEN expression
        {
                /* type check */
                if($2->S_type != type::BOOL_TYPE)
                        yyerror("type mismatch");
                G_When();
        }
        |
        ;

expression:    expression '+' expression
        {
                /* type check */
                if($1->S_type != $3->S_type)
                        cout << "WARNING:type mismatch" << endl;

                
                if($1->S_type == type::INT_TYPE)
                        $$ = intConst($1->S_data.int_data + $3->S_data.int_data);
                else if($1->S_type == type::REAL_TYPE)
                        $$ = realConst($1->S_data.real_data + $3->S_data.real_data);
                else
                        yyerror("operator error");
                G_Operator(op::A_D_D);
        }
        |   expression '-' expression
        {
                /* type check */
                if($1->S_type != $3->S_type)
                        cout << "WARNING:type mismatch" << endl;

                
                if($1->S_type == type::INT_TYPE)
                        $$ = intConst($1->S_data.int_data - $3->S_data.int_data);
                else if($1->S_type == type::REAL_TYPE)
                        $$ = realConst($1->S_data.real_data - $3->S_data.real_data);
                else
                        yyerror("operator error");
                cout <<"Reduce exp - exp"<<endl;
                G_Operator(op::S_U_B);
        }
        |   expression '*' expression
        {
                /* type check */
                if($1->S_type != $3->S_type)
                        cout << "WARNING:type mismatch" << endl;

                
                if($1->S_type == type::INT_TYPE)
                        $$ = intConst($1->S_data.int_data * $3->S_data.int_data);
                else if($1->S_type == type::REAL_TYPE)
                        $$ = realConst($1->S_data.real_data * $3->S_data.real_data);
                else
                        yyerror("operator error");
                
                G_Operator(op::M_U_L);
        }
        |   expression '/' expression
        {
                /* type check */
                if($1->S_type != $3->S_type)
                        cout << "WARNING:type mismatch" << endl;

                
                if($1->S_type == type::INT_TYPE)
                        $$ = intConst($1->S_data.int_data / $3->S_data.int_data);
                else if($1->S_type == type::REAL_TYPE)
                        $$ = realConst($1->S_data.real_data / $3->S_data.real_data);
                else
                        yyerror("operator error");
                
                G_Operator(op::D_I_V);
        }
        |   expression MOD expression
        {
                /* type check */
                if($1->S_type != $3->S_type)
                        cout << "WARNING:type mismatch" << endl;

                
                if($1->S_type == type::INT_TYPE)
                        $$ = intConst($1->S_data.int_data % $3->S_data.int_data);
                else
                        yyerror("operator error");
                
                G_Operator(op::M_O_D);
        }
        |   '-' expression    %prec UMINUS
        {
                if($2->S_type == type::INT_TYPE)
                        $$ = intConst(-$2->S_data.int_data);
                else if($2->S_type == type::REAL_TYPE)
                        $$ = realConst(-$2->S_data.real_data);
                else
                        yyerror("operator error");

                cout <<"Reduce - exp"<<endl;
                G_Operator(op::N_E_G);
        }
        |   expression AND expression
        {
                /* type check */
                if($1->S_type != $3->S_type)
                        cout << "WARNING:type mismatch" << endl;

                
                if($1->S_type == type::BOOL_TYPE)
                        $$ = boolConst($1->S_data.bool_data && $3->S_data.bool_data);
                else
                        yyerror("operator error");
                G_Operator(op::A_N_D);
                
        }
        |   expression OR expression
        {
                /* type check */
                if($1->S_type != $3->S_type)
                        cout << "WARNING:type mismatch" << endl;

                
                if($1->S_type == type::BOOL_TYPE)
                        $$ = boolConst($1->S_data.bool_data || $3->S_data.bool_data);
                else
                        yyerror("operator error");
                
                G_Operator(op::O_R);
        }
        |   NOT expression
        {
                
                if($2->S_type == type::BOOL_TYPE)
                        $$ = $2;
                else
                        yyerror("operator error");
                
                G_Operator(op::N_O_T);
                
        }
        |   expression '<' expression
        {
                /* type check */
                if($1->S_type != $3->S_type)
                        cout << "WARNING:type mismatch" << endl;

                
                if($1->S_type == type::INT_TYPE)
                        $$ = boolConst($1->S_data.int_data < $3->S_data.int_data);
                else if($1->S_type == type::REAL_TYPE)
                        $$ = boolConst($1->S_data.real_data < $3->S_data.real_data);
                else
                        yyerror("operator error");
                
                G_Compare(condition::IFLT);  
        }
        |   expression LE  expression
        {
                /* type check */
                if($1->S_type != $3->S_type)
                        cout << "WARNING:type mismatch" << endl;

                
                if($1->S_type == type::INT_TYPE)
                        $$ = boolConst($1->S_data.int_data <= $3->S_data.int_data);
                else if($1->S_type == type::REAL_TYPE)
                        $$ = boolConst($1->S_data.real_data <= $3->S_data.real_data);
                else
                        yyerror("operator error");
                
                G_Compare(condition::IFLE);  
        }
        |   expression '=' expression
        {
                /* type check */
                if($1->S_type != $3->S_type)
                        cout << "WARNING:type mismatch" << endl;

                if($1->S_type == type::INT_TYPE)
                        $$ = boolConst($1->S_data.int_data == $3->S_data.int_data);
                else if($1->S_type == type::REAL_TYPE)
                        $$ = boolConst($1->S_data.real_data == $3->S_data.real_data);
                else if($1->S_type == type::BOOL_TYPE)
                        $$ = boolConst($1->S_data.bool_data == $3->S_data.bool_data);
                else
                        yyerror("operator error");
                
                G_Compare(condition::IFEE);  
        }
        |   expression GE expression
        {
                /* type check */
                if($1->S_type != $3->S_type)
                        cout << "WARNING:type mismatch" << endl;

                if($1->S_type == type::INT_TYPE)
                        $$ = boolConst($1->S_data.int_data >= $3->S_data.int_data);
                else if($1->S_type == type::REAL_TYPE)
                        $$ = boolConst($1->S_data.real_data >= $3->S_data.real_data);
                else
                        yyerror("operator error");

                G_Compare(condition::IFGE);  
        }
        |   expression '>' expression
        {
                /* type check */
                if($1->S_type != $3->S_type)
                        cout << "WARNING:type mismatch" << endl;

                if($1->S_type == type::INT_TYPE)
                        $$ = boolConst($1->S_data.int_data > $3->S_data.int_data);
                else if($1->S_type == type::REAL_TYPE)
                        $$ = boolConst($1->S_data.real_data > $3->S_data.real_data);
                else
                        yyerror("operator error");

                G_Compare(condition::IFGT);  
        }
        |   expression NOT_EQU expression
        {
                /* type check */
                if($1->S_type != $3->S_type)
                        cout << "WARNING:type mismatch" << endl;

                if($1->S_type == type::INT_TYPE)
                        $$ = boolConst($1->S_data.int_data != $3->S_data.int_data);
                else if($1->S_type == type::REAL_TYPE)
                        $$ = boolConst($1->S_data.real_data != $3->S_data.real_data);
                else if($1->S_type == type::BOOL_TYPE)
                        $$ = boolConst($1->S_data.bool_data != $3->S_data.bool_data);
                else
                        yyerror("operator error");
                G_Compare(condition::IFNE);  
        }
        |   '(' expression ')'
        {
                $$ = $2;
        }
        |   IDENTIFIER
        {
                /* check if the identifier is in the symbol table */
                if(symtab.global_lookup(*($1)) == NULL)
                        yyerror("Not defined error");
                
                if(symtab.global_lookup(*($1))->S_flag == flag::FUNC)
                        yyerror("Not a variable error");
                        
                $$ = symtab.global_lookup(*($1));
                Symbol *temp = symtab.global_lookup(*($1));
                if(temp->S_flag == flag::CONSTANT)
                {
                        if(temp->S_type == type::INT_TYPE)
                                G_const_Int(temp->S_data.int_data);
                        else if(temp->S_type == type::BOOL_TYPE)
                                G_const_Bool(temp->S_data.bool_data);
                        else if(temp->S_type == type::STRING_TYPE)
                                G_const_Str(temp->S_data.string_data);
                }
                else
                {
                        int index = symtab.global_lookup(*($1))->index;
                        if(index == -1)
                                G_get_global_Var(*$1);
                        else
                                G_get_local_Var(index);
                }
        }
        |   constant_exp
        {
                if($1->S_type == type::INT_TYPE)
                        G_const_Int($1->S_data.int_data);
                else if($1->S_type == type::BOOL_TYPE)
                        G_const_Bool($1->S_data.bool_data);
                else if($1->S_type == type::STRING_TYPE)
                        G_const_Str($1->S_data.string_data);
                        
        }
        |   function_procedure
        |   array_reference
        ;
function_procedure:     IDENTIFIER '(' argument_body ')'
        {
                /* check if the identifier is in the symbol table */
                if(symtab.global_lookup(*($1)) == NULL)
                        yyerror("Not defined error");
                else if (symtab.global_lookup(*($1))->S_flag != flag::FUNC)
                        yyerror("Not a function error");
                else if (symtab.global_lookup(*($1))->param_num != param_num)
                        yyerror("Parameter number mismatch");
                else
                {
                        param_num = 0;
                        $$ = symtab.global_lookup(*($1));
                        Symbol *temp = symtab.global_lookup(*($1));
                        G_call_Func(*temp);
                }
                       
        }
        ;

array_reference:    IDENTIFIER '[' expression ']'
        {
                /* check if the identifier is in the symbol table */
                if(symtab.global_lookup(*($1)) == NULL)
                        yyerror("Not defined error");
                else if (symtab.global_lookup(*($1))->S_flag != flag::ARRAY_FLAG)
                        yyerror("Not an array error");
                else if($3->S_type != type::INT_TYPE)
                        yyerror("Array index must be an integer");
                else                        
                        $$ = symtab.global_lookup(*($1));
        }
        ;
argument_body:  arguments
        |
        ;
arguments:  arguments ',' func_expression
        |   func_expression
        ;
func_expression: expression
        {
                param_num++;
        }
        ;

if_head : IF expression THEN 
        {
                int temp = symtab.tables.back().index;
                symtab.push();
                symtab.tables.back().index = temp;
        }
        function_bodys
        {
                cout<<"<-----------------------local variable------------------->"<<endl;
                symtab.tables.back().dump();
                cout<<"<-----------------------local variable end--------------->"<<endl;
                int temp = symtab.tables.back().index;
                symtab.pop();
                symtab.tables.back().index = temp;

                if($2->S_type != type::BOOL_TYPE)
                        yyerror("Condition must be a boolean");
                
                G_If_Start();
        
        }
condition:  if_head ELSE
        {
                G_If_Else();
                int temp = symtab.tables.back().index;
                symtab.push();
                symtab.tables.back().index = temp;
        }
        function_bodys END IF
        {
                cout<<"<-----------------------local variable------------------->"<<endl;
                symtab.tables.back().dump();
                cout<<"<-----------------------local variable end--------------->"<<endl;
                int temp = symtab.tables.back().index;
                symtab.pop();
                symtab.tables.back().index = temp;
                G_If_Else_End();
        }
        |   if_head END IF
        {
                G_If_End();
        }
        ;

loop:   LOOP
        {
                int temp = symtab.tables.back().index;
                symtab.push();
                symtab.tables.back().index = temp;
                G_Loop_Start();
        } 
        function_bodys END LOOP
        {
                cout<<"<-----------------------local variable------------------->"<<endl;
                symtab.tables.back().dump();
                cout<<"<-----------------------local variable end--------------->"<<endl;
                int temp = symtab.tables.back().index;
                symtab.pop();
                symtab.tables.back().index = temp;
                G_Loop_End();
        }
        |   FOR decreasing
        {
                int temp = symtab.tables.back().index;
                symtab.push();
                symtab.tables.back().index = temp;
        }        
        IDENTIFIER
        {
                /* check if the identifier is already in the symbol table */
                /*
                if(symtab.lookup(*($4)) != NULL)
                        yyerror("variable redefine");
                
                Symbol s;
                s.init = false;
                s.S_type = type::INT_TYPE;
                s.S_flag = flag::VARIABLE;
                symtab.insert(*($4), s);
                */
        }
        ':' number
        {
                G_const_Int($7->S_data.int_data);
                if(symtab.global_lookup(*($4))->index == -1)
                        G_set_global_Var(*($4));
                else
                        G_set_local_Var(symtab.global_lookup(*($4))->index);
                
        } 
        '.' '.' number
        {
                if($7->S_flag != flag::CONSTANT || $11->S_flag != flag::CONSTANT)
                        yyerror("Index must be a variable");

                if($7->S_type != type::INT_TYPE || $11->S_type != type::INT_TYPE)
                        yyerror("Index must be an integer");
                
                G_Loop_Start();
                if(symtab.global_lookup(*($4))->index == -1)
                        G_For(*($4), $11->S_data.int_data);
                else
                        G_For(symtab.global_lookup(*($4))->index, $11->S_data.int_data);
                G_Compare(condition::IFGT);
                G_When();
                
        }
        function_bodys
        {
                G_For_Body(*$4);
        } 
        END FOR
        {
                cout<<"<-----------------------local variable------------------->"<<endl;
                symtab.tables.back().dump();
                cout<<"<-----------------------local variable end--------------->"<<endl;
                int temp = symtab.tables.back().index;
                symtab.pop();
                symtab.tables.back().index = temp;
                G_Loop_End();
        }
        
        ;
decreasing:     DECREASING
        |
        ;
%%


void yyerror(string s){
        cerr << "yyerror: line " << linenum << ": " << s << endl;

  	exit(1);
}


int main(int argc, char *argv[])
{
    /* open the source program file */
    if (argc != 2) {
        printf ("Usage: sc filename\n");
        exit(1);
    }
    yyin = fopen(argv[1], "r");         /* open input file */
    

    filename = string(argv[1]);
    std::vector<std::string> tokens;
    std::string token;
    std::stringstream ss(filename);
    while (getline(ss, token, '/')){
        tokens.push_back(token);
    }
    className = tokens.back();
    className.pop_back();
    className.pop_back();
    className.pop_back();
    filename += ".jasm";
    string jasmfolder = "jasmFile";
    filename = filename.replace(2,4,jasmfolder,0,8);
        	
    output.open(filename);

    output << "/*------------------------------------------------*/" << endl;
    output << "/*              Java Assembly Code                */" << endl;
    output << "/*------------------------------------------------*/" << endl;

    /* perform parsing */
    if (yyparse() == 1)                 /* parsing */
        yyerror("Parsing error !");     /* syntax error */

        printf("Global SymbolTable:\n");
        symtab.dump();
}