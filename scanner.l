%{
#include<stdio.h>
#include<string.h>

#define LIST     strcat(buf,yytext)
#define token(t) {LIST; printf("<%s>\n",#t);}
#define tokenInteger(t,i) {LIST; printf("<%s:%d>\n",#t,i);}
#define tokenREAL(t,i) {LIST; printf("<%s:%f>\n",#t,i);}
#define tokenString(t,s) {LIST; printf("<%s:%s>\n",#t,s);}
#define yyDebug(s) printf("%s",s);

#define MAX_LINE_LENG 256

int linenum = 1;
char buf[MAX_LINE_LENG];
char strTemp[MAX_LINE_LENG];

%}

digit [0-9]
digits {digit}+
INTEGER {digits}

REALNUMBER {digits}+"."{digits}+

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

">"     {token(LARGER);}
"<"     {token(SMALLER);}
">="    {token(LARGER_THAN_EQUAL);}
"<="    {token(SMALLER_THAN_EQUAL);}

    /*==========operator==========*/

"+" {token(PLUS);}
"-" {token(MINUS);}
"*" {token(MULTIPLE);}
"/" {token(DIVISION);}

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


"("     {token(LEFT_ROUND_BRACKET);}
")"     {token(RIGHT_ROUND_BRACKET);}
"["     {token(LEFT_SQUARE_BRACKET);}
"]"     {token(RIGHT_SQUARE_BRACKET);}
"{"     {token(LEFT_CURLY_BRACKET);}
"}"     {token(RIGHT_CURLY_BRACKET);}
":"     {token(COLON);}
";"     {token(SEMICOLON);}
","     {token(COMMA);}

"="     {token(ASSIGNMENT);}



\n      {
            LIST;
            printf("%d: %s", linenum++, buf);
            buf[0] = '\0';
        }

{INTEGER}   {
                int number;
                sscanf(yytext,"%d",&number);
                tokenInteger(INTEGER,number);
            }

{REALNUMBER}      {
                double number;
                sscanf(yytext,"%lf",&number);
                tokenREAL(DOUBLE,number);
            }

{ID}        {
                token(ID);
                printf("id:%s\n",yytext);
            }

[ \t]*  {LIST;}

\'      {
            LIST;
            BEGIN(STRING);
            strTemp[0]='\0';
        }

\"      {
            LIST;
            strTemp[0]='\0';
            BEGIN(STRING);
        }

<STRING>\"      {
                    strcat(buf,strTemp);
                    BEGIN(INITIAL);
                    tokenString(STRING,strTemp);
                }


<STRING>\'      {
                    strcat(buf,strTemp);
                    BEGIN(INITIAL);
                    tokenString(STRING,strTemp);
                }


    /*==========Escape sequences==========*/

<STRING>\\\\    {strcat(strTemp,"\\");}

<STRING>\\t     {strcat(strTemp,"\t");}

<STRING>\\n     {strcat(strTemp,"\n");}

<STRING>\\\"     {strcat(strTemp,"\"");}

<STRING>\\\'     {strcat(strTemp,"\'");}

<STRING>\\?     {strcat(strTemp,"\?");}

<STRING>.       {strcat(strTemp,yytext);}

    /*====comment=====*/

"//"    {LIST;BEGIN(COMMENT);}

<COMMENT>\n    {
                    LIST;
                    printf("%d: %s", linenum++, buf);
                    buf[0] = '\0';
                    BEGIN(INITIAL);
                }

<COMMENT>.     {LIST;}

    /* C_STYLE_COMMENT */
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
        exit(-1);
        }

%%


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
}