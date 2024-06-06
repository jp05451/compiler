%{
#include<iostream>
#include<string.h>
#include"y.tab.hpp"

#define LIST     strcat(buf,yytext)

// #define token(t) {LIST; printf("<%s>\n",#t);}
// #define tokenINT_VALUE(t,i) {LIST; printf("<%s:%d>\n",#t,i);}
// #define tokenREAL(t,i) {LIST; printf("<%s:%f>\n",#t,i);}
// #define tokenString(t,s) {LIST; printf("<%s:%s>\n",#t,s);} 

#define token(t) {LIST; printf("<%s>\n",#t);return t;}
#define tokenINT_VALUE(t,i) {LIST; printf("<%s:%d>\n",#t,i);return t;}
#define tokenREAL(t,i) {LIST; printf("<%s:%f>\n",#t,i);return t;}
#define tokenString(t,s) {LIST; printf("<%s:%s>\n",#t,s);return t;} 
#define yyDebug(s) printf("%s",s);

#define MAX_LINE_LENG 256

int linenum = 1;
char buf[MAX_LINE_LENG];
char strTemp[MAX_LINE_LENG];

%}

digit [0-9]
digits {digit}+
INT_VALUE {digits}

REAL_VALUE {digits}+"."{digits}+

alphaBat [a-zA-Z]
ID ({alphaBat}|"_")+({digits}|{alphaBat}|"_")*

%x COMMENT
%x STRING
%x CHARACTER
%x C_STYLE_COMMENT


%%

    /*----variable type-----*/
var     {token(VAR);}
val     {token(VAL);}

bool    {token(BOOL);}
char    {token(CHAR);}
int     {token(INT);}
real    {token(REAL);}

class   {token(CLASS);}
   
    /*----bool value-----*/

true    {token(TRUE);}
false   {token(FALSE);}

    /*==========bool operator==========*/

"=="    {token(EQUAL);}    
"!="    {token(NOT_EQUAL);}

">"     {token('>');}
"<"     {token('<');}
">="    {token(MORE_EQUAL);}
"<="    {token(LESS_EQUAL);}

    /*==========operator==========*/

"+" {token('+');}
"-" {token('-');}
"*" {token('*');}
"/" {token('/');}
"%" {token('%');}

    /*==========KeyWord==========*/

if          {token(IF);}
else        {token(ELSE);}
for         {token(FOR);}
while       {token(WHILE);}
do          {token(DO);}
switch      {token(SWITCH);}
case        {token(CASE);}

fun     {token(FUNCTION);}
ret     {token(RETURN);}
main    {token(MAIN);}
print   {token(PRINT);}
println   {token(PRINTLN);}

    /* "("     {token(LEFT_ROUND_BRACKET);}
    ")"     {token(RIGHT_ROUND_BRACKET);}
    "["     {token(LEFT_SQUARE_BRACKET);}
    "]"     {token(RIGHT_SQUARE_BRACKET);}
    "{"     {token(LEFT_CURLY_BRACKET);}
    "}"     {token(RIGHT_CURLY_BRACKET);}
    ":"     {token(COLON);}
    ";"     {token(SEMICOLON);}
    ","     {token(COMMA);}

    "="     {token(ASSIGNMENT);} */

    "("     {token('(');}
    ")"     {token(')');}
    "["     {token('[');}
    "]"     {token(']');}
    "{"     {token('{');}
    "}"     {token('}');}
    ":"     {token(':');}
    ";"     {token(';');}
    ","     {token(',');}
    "="     {token('=');}



\n      {
            LIST;
            printf("%d: %s", linenum++, buf);
            buf[0] = '\0';
        }

{INT_VALUE}   {
                int number;
                sscanf(yytext,"%d",&number);
                tokenINT_VALUE(INT_VALUE,number);
                // yylval.int_value=number;
            }

{REAL_VALUE}      {
                double number;
                sscanf(yytext,"%lf",&number);
                // yylval.real_value=number;
                tokenREAL(REAL_VALUE,number);

            }

{ID}        {
                printf("id:%s\n",yytext);
                token(ID);
            }

[ \t]*  {LIST;}

\'      {
            LIST;
            strTemp[0]='\0';
            BEGIN(STRING);
        }





        /*==========string state==========*/
\"      {
            LIST;
            strTemp[0]='\0';
            BEGIN(STRING);
        }

<STRING>\"      {
                    strcat(buf,strTemp);
                    BEGIN(INITIAL);
                    // strcpy(yylval.stringValue,strTemp);
                    tokenString(STR,strTemp);
                }

<STRING>\'      {
                    strcat(buf,strTemp);
                    BEGIN(INITIAL);
                    // strcat(yylval.stringValue,strTemp);
                    tokenString(STR,strTemp);
                }
    /*==========Escape sequences==========*/

<STRING>\\\\    {strcat(strTemp,"\\");}

<STRING>\\t     {strcat(strTemp,"\t");}

<STRING>\\n     {strcat(strTemp,"\n");}

<STRING>\\\"    {strcat(strTemp,"\"");}

<STRING>\\\'    {strcat(strTemp,"\'");}

<STRING>\\?     {strcat(strTemp,"\?");} 
<STRING>\n      {
                    printf("Bad Charactor\n");      
                    linenum++;        
                    exit(0);
                } 

<STRING>.       {strcat(strTemp,yytext);}





    /*==========comment==========*/

"//"    {LIST;BEGIN(COMMENT);}

<COMMENT>\n    {
                    LIST;
                    printf("%d: %s", linenum++, buf);
                    buf[0] = '\0';
                    BEGIN(INITIAL);
                }

<COMMENT>.     {LIST;}

    /*==========C_STYLE_COMMENT==========*/

"/*"    {   
            LIST;
            BEGIN(C_STYLE_COMMENT);
        }

<C_STYLE_COMMENT>"*/"   {
                            LIST;
                            BEGIN(INITIAL);
                        }
<C_STYLE_COMMENT>\n     {
                            LIST;
                            printf("%d: %s",linenum++,buf);
                            buf[0]='\0';
                        }               
<C_STYLE_COMMENT>.      {LIST;}         

.       {
        LIST;
        printf("%d:%s\n", linenum+1, buf);
        printf("bad character:'%s'\n",yytext);
        exit(0);
        }

%%

/* 
int main(int argc, char *argv[]) 
{

    // read input arg

    if (argc < 2) {
        fprintf(stderr, "Usage: %s filename\n", argv[0]);
        return 1;
    }

    //open input text
    FILE *file = fopen(argv[1], "r");

    if (!file) {
        perror("Error opening file");
        return 1;
    }       
    yyin = file; 
    yylex(); 

    fclose(file); 
    return 0;
} */