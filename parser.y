%{
#include<string.h>
#include "lex.yy.cpp"
#include "symbolTable.hpp"
#include <fstream>
#include <iostream>
#pragma once

#define Trace(t)        printf(t)
// int yylex();
void yyerror(char *);

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
program:        declarations statments mainFunction
                |
                ;

mainFunction:   FUNCTION MAIN '(' ')' '{'
                declarations
                statments
                '}'

declarations:   declaration declarations
                |
                ;

declaration:    constant
                |variable
                |function
                ;

constant:       VAL ID ':' Type '=' expressions ';'
                |VAL ID ':' Type '[' INT_VALUE ']' '=' '{' arrayVal '}' ';'
                ;

variable:       VAR ID ':' Type ';'
                {
                }
                |VAR ID ':' Type '=' expressions ';'
                {
                }
                |VAR ID ':' Type '[' INT_VALUE ']' '=' '{' arrayVal '}' ';'
                ;

Type:           BOOL    
                |INT    
                |REAL   
                |CHAR   
                ;

arrayVal:       expressions arrayVal
                |',' arrayVal
                |
                ;

statments:      statment statments
                |
                ;



statment:       //block
                |simple
                |expressions
                |function
                /* |conditional */
                /* |loop */
                |
                ;

simple:         ID '=' expressions ';'
                |PRINT '(' expressions ')' ';'
                |PRINT '(' STR ')' ';'
                |PRINT '(' CHAR ')' ';'
                |PRINTLN '(' expressions ')' ';'
                |

function:       FUNCTION ID '(' ')' ':' Type
                '{'
                {
                }
                contents
                '}'
                {
                }
                |FUNCTION ID '(' functionVarA functionVarB ')' ':' Type
                ''
                {
                }
                contents
                '}'
                {
                }
                ;



functionVarA:   ID ':' Type
                {
                }

                ;

functionVarB:   functionVarB ',' ID ':' Type
                {
                }
                |
                ;

contents:       content contents
                ;

content:        variable    
                |constant
                |statment
                |
                ;


expressions:    '-' expressions %prec NEGATIVE  
                {
                }
                |'(' expressions ')'
                |expressions '*' expressions
                {
                }
                |expressions '/' expressions
                {
                }
                |expressions '%' expressions
                {
                }
                |expressions '+' expressions
                {
                }
                |expressions '-' expressions
                {
                }
                |bool_expression    
                {
                }
                |const_exp          

                |function
                {
                }
                |ID '[' INT_VALUE ']'
                {
                }
                |ID
                {
                }
                ;
const_exp:      INT_VALUE      
                |REAL_VALUE    
                ;

bool_expression:    '(' bool_expression ')'
                    |expressions '<' expressions   
                    {
                    }     
                    |expressions 'LESS_EQUAL' expressions
                    {
                    }     
                    |expressions '=' expressions
                    {
                    }     
                    |expressions MORE_EQUAL expressions
                    {
                    }     
                    |expressions '>' expressions
                    {
                    }     
                    |expressions NOT_EQUAL expressions
                    {
                    }     
                    |NOT expressions
                    {
                    }
                    |expressions AND expressions
                    {
                    }     
                    |expressions OR expressions
                    {
                    }     
                    ;

BOOL_VALUE:     TRUE
                |FALSE
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
        yyerror("Parsing error !");     /* syntax error */
}
