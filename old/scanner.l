%{
#include<stdio.h>
// #include"y.tab.hpp"
#include"symbolTable.hpp"

#define LIST     strcat(buf,yytext)
//#define token(t) {LIST; printf("<%s>\n",#t);}
#define token(t) {LIST; printf("<%s>\n",#t); return t;}

//#define tokenInteger(t,i) {LIST; printf("<%s:%d>\n",#t,i);}
#define tokenInteger(t,i) {LIST; printf("<%s:%d>\n",#t,i); return t;}

//#define tokenInteger(t,i) {LIST; printf("<%s:%d>\n",#t,i);}
#define tokenReal(t,i) {LIST; printf("<%s:%f>\n",#t,i); return t;}


//#define tokenString(t,s) {LIST; printf("<%s:%s>\n",#t,s);}
#define tokenString(t,s) {LIST; printf("<%s:%s>\n",#t,s); return t;}
// #define yyDebug(s) printf("%s",s);


int linenum = 1;
char buf[MAX_LINE_LENG];
char strTemp[MAX_LINE_LENG];
// symbolTable s_table;
// enum dataType{type_int,type_real,type_string,type_bool,type_array,type_function};
%}

digit [0-9]
digits {digit}+
numerical {digits}+("."{digits}+)?
integer {digits}+

alphaBat [a-zA-Z]
ID {alphaBat}+({digits}|{alphaBat})*


%x STRING_STATE
%x COMMENT
%x COMMENT_LINES

%%
        /*==========Delimiters==========*/
"."     {token('.');}
","     {token(',');}
":"     {token(':');}
";"     {token(';');}
"("     {token('(');}
")"     {token(')');}
"["     {token('[');}
"]"     {token(']');}
"{"     {token('{');}
"}"     {token('}');}

        /*==========Arithmetic, Relational, and Logical Operators==========*/
"+"     {token('+');}
"-"     {token('-');}
"*"     {token('*');}
"/"     {token('/');}
"mod"   {token(MOD);}
":="    {token(ASSIGN);}
"<"     {token('<');}
"<="    {token(LESS_EQUAL);}
">"     {token('>');}
">="    {token(MORE_EQUAL);}
"="     {token('=');}
"not="  {token(NOT_EQUAL);}
"and"   {token(AND);}
"or"    {token(OR);}
"not"   {token(NOT);}


        /*==========KeyWord==========*/
begin           {token(BEG);}
array           {token(ARRAY);}
bool            {
                yylval.dType=type_bool;
                token(BOOL);
                }
char            {token(CHAR);}
const           {token(CONST);}
decreasing      {token(DECREASING);}
default         {token(DEFAULT);}
do              {token(DO);}
else            {token(ELSE);}
end             {token(END);}
exit            {token(EXIT);}
false           {
                yylval.info.dType=type_bool;
                yylval.info.value.boolValue=false;
                token(FALSE);
                }
for             {token(FOR);}
function        {token(FUNCTION);}
get             {token(GET);}
if              {token(IF);}
int             {
                yylval.dType=type_int;
                token(INT);
                }
loop            {token(LOOP);}
of              {token(OF);}
put             {token(PUT);}
procedure       {token(PROCEDURE);}
real            {
                yylval.dType=type_real;
                token(REAL);
                }
result          {token(RESULT);}
return          {token(RETURN);}
skip            {token(SKIP);}
string          {
                yylval.dType=type_string;
                token(STRING);
                }
then            {token(THEN);}
true            {
                yylval.info.dType=type_bool;
                yylval.info.value.boolValue=true;
                token(TRUE);
                }
var             {token(VAR);}
when            {token(WHEN);}


        /*==========Identity==========*/
{ID}            {
                sprintf(yylval.info.tokenID,"%s",yytext);

                token(ID);
                }

{integer}       {
                int intNumber;
                sscanf(yytext,"%d",&intNumber);
                yylval.info.dType=type_int;
                yylval.info.value.intValue=intNumber;
                tokenInteger(INT_NUMBER,intNumber);
}
{numerical}     {
                double doubleNumber;
                sscanf(yytext,"%lf",&doubleNumber);
                printf("%f\n",doubleNumber);
                yylval.info.dType=type_real;
                yylval.info.value.doubleValue=doubleNumber;
                tokenReal(REAL_NUMBER,doubleNumber);
                }


        /*==========STRING==========*/

\"                      {
                                // strcat(buf,"\"");
                                strTemp[0]='\0';
                                BEGIN(STRING_STATE);
                        }

<STRING_STATE>\n        {
                                printf("Bad Charactor\n");      
                                linenum++;        
                                YYABORT;
                        } 



<STRING_STATE>\"\"      {strcat(strTemp,"\"");}


<STRING_STATE>\"        {
                        yytext=strTemp;
                        BEGIN(INITIAL);
                        yylval.info.dType=type_string;
                        strcpy(yylval.info.stringValue,strTemp);
                        tokenString(STR,strTemp);
                        }

<STRING_STATE>[^\"]*    {strcat(strTemp,yytext);}


        /*==========COMMENT==========*/
%               {
                LIST;
                BEGIN(COMMENT);
                }
<COMMENT>\n     {
                LIST;
                printf("%d: %s", linenum++, buf);
                buf[0] = '\0';
                BEGIN(INITIAL);
                }
<COMMENT>.      {LIST;}

        /*/*==========COMMENT_LINE/*==========*/
"{%"    {
        LIST;
        BEGIN(COMMENT_LINES);
        }

<COMMENT_LINES>"%}"     {
                        LIST;
                        BEGIN(INITIAL);
                        }

<COMMENT_LINES>\n       {
                        LIST;
                        printf("%d: %s", linenum++, buf);
                        buf[0] = '\0';
                        }    
<COMMENT_LINES>.        {LIST;}



        /*==========next line==========*/
\n      {
        LIST;
        java<<"/*"<<linenum<<": "<<buf<<"*/"<<endl;
        printf("%d: %s", linenum++, buf);
        buf[0] = '\0';
        }


        /*==========white space==========*/
[ \t]*  {LIST;}

.       {
        LIST;
        printf("%d:%s\n", linenum+1, buf);
        printf("bad character:'%s'\n",yytext);
        exit(-1);
        }
%%



        /* int main(int argc, char *argv[]) {
        if (argc < 2) {
                fprintf(stderr, "Usage: %s filename\n", argv[0]);
                return 1;
        }

        FILE *file = fopen(argv[1], "r");
        if (!file) {
                perror("Error opening file");
                return 1;
        }
                s_table.creat();        
        yyin = file;
        yylex(); 

        fclose(file); 
        s_table.dump();
        return 0;
        } */
