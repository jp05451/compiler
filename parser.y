%{
#include<vector>
#include "lex.yy.cpp"
#include "symbolStack.hpp"

#define Trace(t)        printf(t)
void yyerror(char *msg);
symbolStack symStack;

%}

%union { 
    class symbol *sym;
    double real_value;
    // enum dataType d;
    char dType[10];
    char identity[256];
}


%type <sym> expressions factor term  arrayValue
/* %type <real_value> bool_expression */
%type <sym> const_exp
%type <dType> Type
%type <sym> dymention


/* tokens */

%token <real_value> INT_VALUE REAL_VALUE TRUE FALSE
%token <identity> ID 
%token VAR VAL // define
%token BOOL CHAR INT REAL CLASS STR// data type
%token NOT_EQUAL MORE_EQUAL LESS_EQUAL EQUAL// bool operator
/* %token PLUS MINUS MULTIPLE DIVISION // operator */
%token IF ELSE FOR DO WHILE SWITCH CASE FUNCTION RETURN MAIN PRINT PRINTLN // key word


%left OR
%left AND
%left '<' MORE_EQUAL '=' LESS_EQUAL '>' NOT_EQUAL
%left '+' '-'
%left '*' '/' '%'
%left NOT
%left '[' ']'
%left '(' ')'
%nonassoc NEGATIVE

%%
program:        declarations;

declarations:   declaration declarations
                |
                ;

declaration:    variable
                |constant
                |functionDeclare
                ;

variable:       VAR ID ':' Type ';'
                {
                    symbol s($2);
                    s.S_type=stringToType($4);
                    symStack.insert($2,s);
                }
                |VAR ID ':' Type '=' const_exp ';'
                {
                    symbol s($2);
                    s.S_type = stringToType($4);
                    s.S_data = $6->S_data;
                    symStack.insert($2,s);
                }
                |array
                ;

constant:       VAL ID ':' Type '=' expressions ';'
                {
                    symbol s($2);
                    s.S_type=stringToType($4);
                    s.S_data.real_data=$6->S_data.real_data;
                    s.S_flag=CONSTANT;
                    symStack.insert($2,s);
                    delete $6;
                }
                |VAL ID ':' Type dymention '=' array ';'
                ;

array:      VAR ID ':' Type dymention '=' '{' arrayValue '}' ';'
            {
                symbol s($2);
                s.S_type=stringToType($4);
                s.S_flag=ARRAY_FLAG;
                symStack.insert($2,s);
                printf("size: %d\n",$5->S_data.dymention.size());

            }
            |VAR ID ':' Type dymention ';'
            {
                symbol s($2);
                s.S_type=stringToType($4);
                s.S_flag=ARRAY_FLAG;
                symStack.insert($2,s);
                printf("size: %d\n",$5->S_data.dymention.size());
            }
            ;

dymention:  '[' INT_VALUE ']'
            {
                symbol *s = new symbol;
                s->S_data.dymention.push_back((int)$2);
                $$ = s;
            }
            |dymention dymention
            {
                // symbol s;
                // s.S_data.dymention.insert(s.S_data.dymention.end(),$1->S_data.dymention.begin(),$1->S_data.dymention.begin());
                // s.S_data.dymention.insert(s.S_data.dymention.end(),$2->S_data.dymention.begin(),$1->S_data.dymention.begin());
                // $$ = &s;
            }
            ;

arrayValue: const_exp
            |arrayValue ',' const_exp
            |'{' arrayValue '}'
            |'{' arrayValue '}' ',' '{' arrayValue '}'
            ;

functionDeclare:    FUNCTION ID '(' parameter ')' ':' Type
                    '{'
                        statments
                        RETURN expressions ';'
                    '}'
                    |FUNCTION MAIN '(' parameter ')'
                    '{'
                        statments
                    '}'

parameter:  ID ':' Type
            |parameter ',' parameter
            |
            ;

statments:  statment statments
            |
            ;

statment:   simple
            |declaration
            |block
            |conditional
            ;

simple:     print
            |ID '=' expressions ';' 
            
            ;

print:      PRINT '(' expressions ')' ';'
            |PRINTLN '(' expressions ')' ';'
            |PRINT '(' STR ')' ';'
            |PRINTLN '(' STR ')' ';'
            ;

block:      '{'
                statments    
            '}'


Type:       INT 
            /* {$$ = INT_TYPE;} */
            {strcpy($$,"INT");}
            |REAL 
            /* {$$ = REAL_TYPE;} */
            {strcpy($$ ,"REAL");}
            |CHAR 
            /* {$$ = CHAR_TYPE;} */
            {strcpy($$ ,"CHAR");}
            |BOOL 
            /* {$$ = BOOL_TYPE;} */
            {strcpy($$,"BOOL");}
            ;

conditional:    IF '(' bool_expression ')'
                '{'
                    statments
                '}'

expressions:    factor
                |expressions '+' factor 
                {
                    /* type check */
                    if($1->S_type != $3->S_type)
                            cout << "WARNING:type mismatch" << endl;

                    
                    if($1->S_type == dataType::INT_TYPE)
                            $$ = intConst($1->S_data.int_data + $3->S_data.int_data);
                    else if($1->S_type == dataType::REAL_TYPE)
                            $$ = realConst($1->S_data.real_data + $3->S_data.real_data);
                    else
                            yyerror("operator error");
                }
                |expressions '-' factor
                {
                    /* type check */
                    if($1->S_type != $3->S_type)
                            cout << "WARNING:type mismatch" << endl;

                    
                    if($1->S_type == dataType::INT_TYPE)
                            $$ = intConst($1->S_data.int_data - $3->S_data.int_data);
                    else if($1->S_type == dataType::REAL_TYPE)
                            $$ = realConst($1->S_data.real_data - $3->S_data.real_data);
                    else
                            yyerror("operator error");
                    cout <<"Reduce exp - exp"<<endl;
                }
                ;

factor:         term
                |factor '*' term
                {
                    /* type check */
                    if($1->S_type != $3->S_type)
                            cout << "WARNING:type mismatch" << endl;

                    
                    if($1->S_type == dataType::INT_TYPE)
                            $$ = intConst($1->S_data.int_data * $3->S_data.int_data);
                    else if($1->S_type == dataType::REAL_TYPE)
                            $$ = realConst($1->S_data.real_data * $3->S_data.real_data);
                    else
                            yyerror("operator error");
                }
                |factor '/' term 
                {
                    /* type check */
                    if($1->S_type != $3->S_type)
                            cout << "WARNING:type mismatch" << endl;

                    
                    if($1->S_type == dataType::INT_TYPE)
                            $$ = intConst($1->S_data.int_data / $3->S_data.int_data);
                    else if($1->S_type == dataType::REAL_TYPE)
                            $$ = realConst($1->S_data.real_data / $3->S_data.real_data);
                    else
                            yyerror("operator error");
                
                }
                ;

term:           '(' expressions ')' {$$ = $2;}
                |ID { $$ = symStack.lookup($1); }
                |ID '[' INT_VALUE ']'
                |functionCall
                |'-' expressions %prec NEGATIVE
                {
                }
                |const_exp {$$ = $1;}

                ;


functionCall:   ID '(' inputParameter ')';

inputParameter: expressions
                |inputParameter ',' expressions
                ;

const_exp:      INT_VALUE { $$=intConst($1); }
                |REAL_VALUE {$$ = realConst($1); }
                |TRUE {$$ = boolConst($1);}
                |FALSE {$$ = boolConst($1);}
                ;

bool_expression:    expressions '>' expressions
                    |expressions '<' expressions
                    |expressions MORE_EQUAL expressions
                    |expressions LESS_EQUAL expressions
                    |expressions EQUAL expressions
                    |expressions OR expressions
                    |expressions AND expressions
                    ;
%%

void yyerror(char *msg)
{
    fprintf(stderr, "%s\n", msg);
}


int main(int argc,char **argv)
{
    /* open the source program file */
    if (argc != 2) {
        printf ("Usage: sc filename\n");
        exit(1);
    }
    yyin = fopen(argv[1], "r");         /* open input file */

    /* perform parsing */
    if (yyparse() == 1)                 /* parsing */
        yyerror((char *)"Parsing error !");     /* syntax error */
    symStack.dump();
}
