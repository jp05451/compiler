%{
#include<string.h>
#include "lex.yy.cpp"
#include "symbolTable.hpp"
#include <fstream>
#include <iostream>
#include <string>

#define Trace(t)        printf(t)
// int yylex();
// void yyerror(std::string msg);
void yyerror(char *msg);

%}



%union { 
    int int_value;
    double real_value;
    bool bool_value;
    char charValue;
    char* stringValue;
    char dataIdentity[256];
}

%token <int_value> INT_VALUE
%token <real_value> REAL_VALUE

%token <dataIdentity> ID 

%type <real_value> expressions
%type <real_value> bool_expression
/* %type <dType> const_exp
%type <dType> Types Type array function_invocation functionVarA functionVarB */

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
                |VAR ID ':' type '=' expressions ';'
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


type:       INT
            |REAL
            |CHAR
            |BOOL
            ;

conditional:    IF '(' bool_expression ')'
                '{'
                    statments
                '}'

expressions:    '(' expressions ')'
                |expressions '+' expressions
                |expressions '-' expressions
                |expressions '*' expressions
                |expressions '/' expressions
                |expressions '%' expressions
                |'-' expressions %prec NEGATIVE
                |const_exp
                |bool_expression
                |ID
                |ID '[' INT_VALUE ']'
                |functionCall
                ;

functionCall:   ID '(' inputParameter ')';

inputParameter: expressions
                |inputParameter ',' inputParameter
                ;

const_exp:      INT_VALUE
                |REAL_VALUE
                |TRUE
                |FALSE
                ;

bool_expression:    expressions '>' expressions
                    |expressions '<' expressions
                    |expressions MORE_EQUAL expressions
                    |expressions LESS_EQUAL expressions
                    |expressions EQUAL expressions
                    ;
%%

void yyerror(char *msg)
{
    fprintf(stderr, "%s\n", msg);
}

/* void yyerror(std::string &msg)
{
    fprintf(stderr, "%s\n", msg.c_str());
} */

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
}
