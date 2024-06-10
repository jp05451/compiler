%{

#include "y.tab.hpp"
#define LIST     strcat(buf,yytext)
#define token(t) {LIST; printf("<%s>\n",#t); return t;}
#define tokenNumber(t,i) {LIST; printf("<%s:%d>\n",#t,i); return t;}
#define tokenString(t,s) {LIST; printf("<%s:%s>\n",#t,s); return t;}

#define MAX_LINE_LENG 256

using namespace std;

int linenum = 1;
char buf[MAX_LINE_LENG];


SymbolTable symboltable;
extern ofstream output;
bool commentFlag = false;
%}

/* definitions */
dig [0-9]
digs {dig}+
alphabet [a-zA-Z]
letter {alphabet}+
integer {digs}
real {digs}"."{digs}
numerical_constants {integer}|{real}
string_constants (\"(\"\"|[^\"])*\")
identifier {letter}({letter}|{dig})*

%x COMMENT

%%

    /* delimiters */
"."                    {token('.');}
","                    {token(',');}
":"                    {token(':');}
";"                    {token(';');}
"("                    {token('(');}
")"                    {token(')');}
"["                    {token('[');}
"]"                    {token(']');}
"{"                    {token('{');}
"}"                    {token('}');}

    /* operators */
"+"                    {token('+');}
"-"                    {token('-');}
"*"                    {token('*');}
"/"                    {token('/');}
"mod"                  {token(MOD);}
":="                   {token(ASSIGN);}
"<"                    {token('<');}
"<="                   {token(LE);}
">="                   {token(GE);}
">"                    {token('>');}
"="                    {token('=');}
"not="                 {token(NOT_EQU);}
"and"                  {token(AND);}
"or"                   {token(OR);}
"not"                  {token(NOT);}

    /* keywords */
array                  {token(ARRAY);}
begin                  {token(BEGIN_);}
bool                   {token(BOOL);}
char                   {token(CHAR);}
const                  {token(CONST);}
decreasing             {token(DECREASING);}
default                {token(DEFAULT);}
do                     {token(DO);}
else                   {token(ELSE);}
end                    {token(END);}
exit                   {token(EXIT);}
false                  {token(FALSE);}
for                    {token(FOR);}
function               {token(FUNCTION);}
get                    {token(GET);}
if                     {token(IF);}
int                    {token(INT);}
loop                   {token(LOOP);}
of                     {token(OF);}
put                    {token(PUT);}
procedure              {token(PROCEDURE);}
real                   {token(REAL);}
result                 {token(RESULT);}
return                 {token(RETURN);}
skip                   {token(SKIP);}
string                 {token(STRING);}
then                   {token(THEN);}
true                   {token(TRUE);}
var                    {token(VAR);}
when                   {token(WHEN);}

    /* identifiers */
{identifier}           {symboltable.insert(yytext); yylval.sval=new string(yytext); tokenString(IDENTIFIER, yytext);}
{integer}              {yylval.ival = atoi(yytext); tokenNumber(INT_NUM, atoi(yytext));}
{real}                 {yylval.fval = atof(yytext); tokenString(REAL_NUM, yytext);}

    /* strings */
{string_constants}     {
                        char str[MAX_LINE_LENG] = {0};
                        int idx = 0;
                        for (int i = 1; i < yyleng - 1; ++i) 
                        {
                            if (yytext[i] == '"') ++i;
                            str[idx++] = yytext[i];
                        }
                        yylval.sval = new string(str);
                        tokenString(STRING_CONSTANTS, str);
                       }

    /* comments */
"{%"                  {LIST; BEGIN(COMMENT);}
<COMMENT>"%}"         {LIST; BEGIN(INITIAL); commentFlag = true;}

<COMMENT>\n           {
                        LIST;
                        printf("%d: %s", linenum++, buf);
                        buf[0] = '\0';
                      }
<COMMENT>.            {LIST;}
"%".*                 {LIST; commentFlag = true;}

\n      {
        if(strlen(buf) > 0 && !commentFlag)
            output << "/*\t" << linenum << ": " << buf << "\t*/" << endl;
        commentFlag = false;
        LIST;
        printf("%d: %s", linenum++, buf);
        buf[0] = '\0';
        }


[ \t]*  {LIST;}
    
<<eof>> {
        LIST;
        printf("%d: %s\n", linenum++, buf);
        buf[0] = '\0';
        
        yyterminate();
        }

.       {
        LIST;
        printf("%d:%s\n", linenum+1, buf);
        printf("bad character:'%s'\n",yytext);
        exit(-1);
        }
%%
