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

/* %type <real_value> expressions */
/* %type <> bool_expression
%type <dType> const_exp
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
                |functionDeclare
                ;

variable:       VAR ID ':' type ';'
                |VAR ID ':' type '=' expressions ';'
                |VAR ID ':' type'[' INT_VALUE ']' ';'
                |VAR ID ':' type'[' INT_VALUE ']' '=' array ';'
                ;

array:      '{' arrayValue '}'
            ;

arrayValue: expressions
            |expressions ',' expressions
            |'{' arrayValue '}'
            |'{' arrayValue '}' ',' '{' arrayValue '}'
            ;

functionDeclare:    FUNCTION ID '(' parameter ')' ':'
                    '{'
                    '}'

parameter:  ID ':' type
            |parameter ',' parameter
            |
            ;


type:       INT
            |REAL
            |CHAR
            |BOOL
            ;

expressions: ;
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
