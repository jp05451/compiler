%{
#include "lex.yy.cpp"
#include "symbolStack.hpp"
#include "symbol.hpp"

#define Trace(t)        printf(t)
void yyerror(char *msg);
symbolStack symStack;
%}

%union { 
    class symbol *sym;
    double real_value;
    char dType[10];
    char identity[256];
}

%token <real_value> INT_VALUE REAL_VALUE TRUE FALSE

%token <identity> ID 

%type <sym> expressions factor term
/* %type <real_value> bool_expression */
%type <sym> const_exp
%type <dType> type

/* tokens */
%token VAR VAL // define
%token BOOL CHAR INT REAL CLASS STR// data type
%token TRUE FALSE //bool value
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

variable:       VAR ID ':' type ';'
                {
                    symbol s($2);
                    s.S_type=stringToType($4);
                    symStack.insert($2,s);
                }
                |VAR ID ':' type '=' const_exp ';'
                {
                    symbol s($2);
                    s.S_type=stringToType($4);
                    if(s.S_type != $3)
                    symStack.insert($2,s);


                }
                |array
                ;

constant:       VAL ID ':' type '=' expressions ';'
                |VAL ID ':' type dymention '=' array ';'
                ;

array:      VAR ID ':' type dymention '=' '{' arrayValue '}' ';'
            |VAR ID ':' type dymention ';'
            ;

dymention:  '[' INT_VALUE ']'
            |dymention dymention
            ;

arrayValue: expressions
            |arrayValue ',' arrayValue
            |'{' arrayValue '}'
            |'{' arrayValue '}' ',' '{' arrayValue '}'
            ;

functionDeclare:    FUNCTION ID '(' parameter ')' ':' type
                    '{'
                    statments
                    RETURN expressions ';'
                    '}'
                    |FUNCTION MAIN '(' parameter ')'
                    '{'
                    statments
                    '}'

parameter:  ID ':' type
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


type:       INT {strcpy($$,"INT");}
            |REAL {strcpy($$,"REAL");}
            |CHAR {strcpy($$,"CHAR");}
            |BOOL {strcpy($$,"BOOL");}
            ;

conditional:    IF '(' bool_expression ')'
                '{'
                    statments
                '}'

expressions:    factor
                |expressions '+' factor
                |expressions '-' factor
                /* |bool_expression */
                ;

factor:         term
                |factor '*' term
                |factor '/' term
                /* |factor '*' factor */
                ;

term:           '(' expressions ')'
                |ID
                |ID '[' INT_VALUE ']'
                |functionCall
                |'-' expressions %prec NEGATIVE
                {
                }
                |const_exp

                ;


functionCall:   ID '(' inputParameter ')';

inputParameter: expressions
                |inputParameter ',' inputParameter
                ;

const_exp:      INT_VALUE
                {
                    symbol *s=new symbol;
                    s->S_type=INT_TYPE;
                    s->S_data.int_data=(int)$1;
                    $$=s
                }
                |REAL_VALUE
                {
                    symbol *s=new symbol;
                    s->S_type=REAL_TYPE;
                    s->S_data.int_data=(double)$1;
                    $$=s
                }
                |TRUE
                {
                    symbol *s=new symbol;
                    s->S_type=BOOL_TYPE;
                    s->S_data.bool_data=true;
                    $$=s
                }
                |FALSE
                {
                    symbol *s=new symbol;
                    s->S_type=BOOL_TYPE;
                    s->S_data.bool_data=false;
                    $$=s
                }
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
