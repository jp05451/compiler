%{
#include<string.h>
#include "symbolTable.hpp"
#include <fstream>

#define Trace(t)        printf(t)
// int yylex();
void yyerror(char *);

extern int yylex();
symbolTable s_table;
int currentStack=0;
int stackNumber=0;


vector<tokenInfo> functionVariable;



ofstream java;
string className;
%}


%union {
    // string identity;
    dataType dType;
    tokenInfo info;
}

%token <dType> REAL INT STRING BOOL  
%token <info> ID INT_NUMBER REAL_NUMBER STR TRUE FALSE

%type <info> expressions array function_invocation functionVarA functionVarB
%type <info> bool_expression simple
%type <info> const_exp
%type <dType> Types Type 

/* tokens */
%token ARRAY BEG CHAR  DECREASING DEFAULT DO ELSE END EXIT  FOR FUNCTION GET IF LOOP OF PUT PROCEDURE RESULT RETURN SKIP THEN  VAR WHEN CONST 
%token ASSIGN MOD 
%token LESS_EQUAL MORE_EQUAL NOT_EQUAL AND OR NOT 
/* %token INT_NUMBER REAL_NUMBER STR  */
    /* TRUE FALSE */

%left OR
%left AND
%left NOT
%left '<' LESS_EQUAL '=' MORE_EQUAL '>' NOT_EQUAL
%left '+' '-'
%left '*' '/' MOD
%nonassoc NEGATIVE





%%

program:        declarations statments
                {
                    java<<"method public static void main(java.lang.String[])"<<endl;
                    java<<"max_stack 15"<<endl;
                    java<<"max_locals 15"<<endl;
                    java<<"{"<<endl;
                    java<<"return"<<endl;
                    java<<"}"<<endl;
                }
                ;

declarations:   declarations declaration
                |
                ;

statments:      statments statment
                |
                ;

declaration:    constant
                |variable
                |array
                |function
                |procedure
                ;

statment:       block
                |simple
                |expressions
                |function_invocation
                {
                    functionVariable.clear();
                }
                |conditional
                |loop

constant:       CONST ID ':' Type ASSIGN expressions
                {
                    if($2.dType!=$6.dType)
                        yyerror("ERROR: const assign type error");
                    else
                    {
                        // copyTokenInfo(t,$6);
                        
                        strcpy($6.tokenID,$2.tokenID);
                        $6.is_const=1;
                        s_table.insert($6,currentStack);
                    }
                }
                
                |CONST ID ASSIGN expressions
                {
                    strcpy($4.tokenID,$2.tokenID);
                    $4.is_const=1;
                    s_table.insert($4,currentStack);
                }
                ;

variable:       VAR ID ':' Type
                {
                    $2.dType=$4;
                    cout<<$2.dType<<endl;

                    if(currentStack==0)
                    {
                        java<<"field static "<<typeString[$4]<<endl;
                    }
                    else
                    {
                        $2.javaStackNum=javaStackNumber++;
                    }
                    s_table.insert($2,currentStack);
                }
                |VAR ID ASSIGN expressions
                {
                    // if($4!=$6)
                    //     yyerror("ERROR: var assign type error");
                    $2.dType=$4.dType;
                    $2.value=$4.value;
                    
                    if(currentStack==0)
                    {
                        if($4.dType==type_int)
                            java<<"field static "<<typeString[$4.dType]<<" = "<< $4.value.intValue <<endl;
                        else if($4.dType==type_bool)
                            java<<"field static "<<typeString[$4.dType]<<" = "<< $4.value.boolValue <<endl;
                        $2.javaStackNum=0;
                    }
                    else
                    {
                        $2.javaStackNum=javaStackNumber++;
                        if($4.is_const)
                        {
                            if($4.dType=type_int)
                            {
                                java<<"sipush "<<$4.value.intValue<<endl;
                            }
                            else if($4.dType=type_bool)
                            {
                                java<<"iconst_"<<$4.value.boolValue<<endl;
                            }
                        }
                        java<<"istore "<<javaStackNumber-1<<endl;
                    }
                    s_table.insert($2,currentStack);

                }
                |VAR ID ':' Type ASSIGN expressions
                {
                    if($4!=$6.dType)
                        yyerror("ERROR: const assign type error");
                    else
                    {
                        $2.dType=$4;
                        $2.value=$6.value;
                        if(currentStack==0)
                        {
                            if($4==type_int)
                                java<<"field static "<<typeString[$4]<<" = "<< $6.value.intValue <<endl;
                            else if($4==type_bool)
                                java<<"field static "<<typeString[$4]<<" = "<< $6.value.boolValue <<endl;
                            $2.javaStackNum=0;
                        }
                        else
                        {
                            $2.javaStackNum=javaStackNumber++;
                            if($6.is_const)
                            {
                                if($6.dType=type_int)
                                    java<<"sipush "<<$6.value.intValue<<endl;
                                else if($6.dType=type_bool)
                                {
                                    java<<"iconst_"<<$6.value.boolValue<<endl;
                                }
                            }
                            java<<"istore "<<javaStackNumber-1<<endl;
                        }
                        s_table.insert($2,currentStack);
                    }
                }
                
                ;

Types:          Type    {$$=$1;}  
                |array  {$$=$1.dType;}  
                ;

array:          VAR ID ':' ARRAY  const_exp '.' '.' const_exp OF Type
                {
                    $2.dType=$10;
                    $2.is_array=1;
                    s_table.insert($2,currentStack);
                    copyTokenInfo($$,$2);
                }
                ;

Type:           BOOL        {$$=$1;}
                |INT        {$$=$1;}
                |REAL       {$$=$1;}
                |STRING     {$$=$1;}
                ;

function:       FUNCTION ID '(' ')' ':' Types
                {
                    if(s_table.lookup($2.tokenID)==1)
                    {
                        printf("ERROR: %s is already define\n",$2.tokenID);
                    }
                    $2.dType=$6;
                    $2.is_function=1;
                    s_table.insert($2,0);

                    currentStack=++stackNumber;    
                }
                contents
                END ID
                {
                    currentStack=0;
                }
                |FUNCTION ID '(' functionVarA functionVarB ')' ':' Types
                {
                    
                    if(s_table.lookup($2.tokenID)==1)
                    {
                        printf("ERROR: %s is already define\n",$2.tokenID);
                    }
                    $2.dType=$8;
                    $2.is_function=1;
                    // $2.funcParams.funcParamNumber=0;
                    s_table.insert($2,0);
                    currentStack=++stackNumber;


                    // //copy func param to symboldata
                    for(int i=0;i<functionVariable.size();i++)
                    {
                        //insert variable in functionData
                        s_table.table[$2.tokenID].funcParameters.push_back(functionVariable[i].dType);

                        //insert variable to symbolTable
                        s_table.insert(functionVariable[i],currentStack);
                    }

                }
                contents
                END ID
                {
                    currentStack=0;
                    functionVariable.clear();
                }
                ;



functionVarA:   ID ':' Type
                {
                    tokenInfo temp;
                    strcpy(temp.tokenID,$1.tokenID);
                    temp.dType=$3;
                    temp.is_array=0;

                    //push func parameter to function var
                    functionVariable.push_back(temp);
                }
                |ID ':' ARRAY const_exp '.' '.' const_exp OF Type
                {
                    tokenInfo temp;
                    strcpy(temp.tokenID,$1.tokenID);
                    temp.dType=$9;
                    temp.is_array=1;

                    //push func parameter to function var
                    functionVariable.push_back(temp);
                }
                ;

functionVarB:   functionVarB ',' ID ':' Type
                {
                    tokenInfo temp;
                    strcpy(temp.tokenID,$3.tokenID);
                    temp.dType=$5;
                    temp.is_array=0;

                    //push func parameter to function var
                    functionVariable.push_back(temp);
                }
                |functionVarB ',' ID ':' ARRAY const_exp '.' '.' const_exp OF Type
                {
                    tokenInfo temp;
                    strcpy(temp.tokenID,$1.tokenID);
                    temp.dType=$11;
                    temp.is_array=1;

                    //push func parameter to function var
                    functionVariable.push_back(temp);
                }
                |
                ;

procedure:      PROCEDURE ID '(' ')'
                {
                    if(s_table.lookup($2.tokenID)==1)
                    {
                        printf("ERROR: %s is already define\n",$2.tokenID);
                    }
                    $2.dType=type_null;
                    $2.is_function=1;
                    // $2.funcParams.funcParamNumber=0;
                    s_table.insert($2,0);
                    currentStack=++stackNumber;


                    //copy func param to symboldata
                    for(int i=0;i<functionVariable.size();i++)
                    {
                        //insert variable in functionData
                        s_table.table[$2.tokenID].funcParameters[i]=functionVariable[i].dType;

                        //insert variable to symbolTable
                        s_table.insert(functionVariable[i],currentStack);
                    }

                }
                contents
                END ID
                {
                    // currentStack=0;
                }
                |PROCEDURE ID '(' functionVarA functionVarB ')'
                {
                    if(s_table.lookup($2.tokenID)==1)
                    {
                        printf("ERROR: %s is already define\n",$2.tokenID);
                    }
                    $2.dType=type_null;
                    $2.is_function=1;
                    // $2.funcParams.funcParamNumber=0;
                    s_table.insert($2,0);
                    currentStack=++stackNumber;


                    //copy func param to symboldata
                    for(int i=0;i<functionVariable.size();i++)
                    {
                        //insert variable in functionData
                        s_table.table[$2.tokenID].funcParameters[i]=functionVariable[i].dType;

                        //insert variable to symbolTable
                        s_table.insert(functionVariable[i],currentStack);
                    }
                }
                contents
                END ID
                {
                    currentStack=0;
                    functionVariable.clear();
                }
                ;

contents:       contents content
                |
                ;

content:        variable    
                |constant
                |array
                |statment
                ;


                ;


block:          BEG     
                {
                    scopeStack.push(currentStack);
                    currentStack=++stackNumber;
                    s_table.insertStack(scopeStack.top(),currentStack);
                }
                content
                END     
                {
                    if(scopeStack.empty())
                    {
                        currentStack=0;
                    }
                    else
                    {
                        currentStack=scopeStack.top();
                        scopeStack.pop();
                    }
                }
                ;

simple:         ID ASSIGN expressions
                {
                    if(s_table.lookup($1.tokenID)==0)
                    //symbol is not declare
                    {
                        printf("ERROR: %s not declare\n",$1.tokenID);
                    }
                    else if(s_table.table[$1.tokenID].info.is_const)
                    //symbol is constant
                    {
                        printf("ERROR %s is constant unable to assign\n",$1.tokenID);
                    }
                    else if(s_table.table[$1.tokenID].info.dType!=$3.dType)
                    //type error
                    {
                        printf("ERROR: %s assign type error\n",$1.tokenID);
                    }
                    else if(s_table.canAccess($1.tokenID,currentStack)==0)
                    {
                        printf("ERROR: %s is unable to access\n",$1.tokenID);
                    }   

                }
                |PUT
                {
                    java<<"getstatic java.io.PrintStream java.lang.System.out"<<endl;

                } 
                expressions
                {
                    if($3.dType==type_string)
                    {
                        java<<"invokevirtual void java.io.PrintStream.print(java.lang.String)"<<endl;
                    }
                    if($3.dType==type_int)
                    {
                        java<<"invokevirtual void java.io.PrintStream.print(int)"<<endl;
                    }
                    else if($3.dType==type_bool)
                    {
                        java<<"invokevirtual void java.io.PrintStream.print(boolean)"<<endl;
                    }

                }
                |GET expressions
                |RESULT expressions
                |RETURN
                |EXIT
                |EXIT WHEN bool_expression
                |SKIP
                {
                    java<<"getstatic java.io.PrintStream java.lang.System.out"<<endl;
                    java<<"invokevirtual void java.io.PrintStream.println()"<<endl;
                }
                ;


    //======================expression=====================
expressions:    '-' expressions %prec NEGATIVE  
                {
                    if($2.dType!=type_int && $2.dType!=type_real)
                    {
                        printf("ERROR: %s unable to calculate negetive\n",$2.tokenID);
                    }
                    // $2.value *= -1;
                    copyTokenInfo($$,$2);
                }
                |'(' expressions ')'            {$$=$2;}
                |expressions '*' expressions
                {
                    if($1.dType!=$3.dType)
                        yyerror("ERROR: expression '*' type error");
                    // $$=$1;
                }
                |expressions '/' expressions
                {
                    if($1.dType!=$3.dType)
                        yyerror("ERROR: expression '*' type error");
                    // $$=$1;
                }
                |expressions MOD expressions{
                    if($1.dType!=$3.dType)
                        yyerror("ERROR: expression '*' type error");
                    // $$=$1;
                }
                |expressions '+' expressions
                {
                    if($1.dType!=$3.dType)
                        yyerror("ERROR: expression '*' type error");
                    // $$=$1;
                }
                |expressions '-' expressions
                {
                    if($1.dType!=$3.dType)
                        yyerror("ERROR: expression '*' type error");
                    copyTokenInfo($$,$1);
                    if($1.dType==type_int)
                    {
                        $$.value.intValue=$1.value.intValue-$3.value.intValue;
                    }
                    else if($1.dType==type_real)
                    {
                        $$.value.doubleValue=$1.value.doubleValue-$3.value.doubleValue;
                    }
                }
                |bool_expression    
                {
                    copyTokenInfo($$,$1);
                }
                |const_exp          
                {
                    copyTokenInfo($$,$1);
                }
                |function_invocation
                {
                    // functionVariable.clear();
                }
                |ID '[' INT_NUMBER ']'
                {
                    if(s_table.lookup($1.tokenID)==0)
                    {
                        printf("ERROR: ID %s not found\n",$1.tokenID);
                    }
                    else if(s_table.canAccess($1.tokenID,currentStack)==0)
                    {
                        printf("ERROR: %s is unable to reach\n",$1.tokenID);
                        copyTokenInfo($$,s_table.table[$1.tokenID].info);
                    }
                    else
                        copyTokenInfo($$,s_table.table[$1.tokenID].info);
                }
                |ID
                {
                    if(s_table.lookup($1.tokenID)==0)
                    {
                        printf("ERROR: ID %s not found\n",$1.tokenID);
                    }
                    else if(s_table.canAccess($1.tokenID,currentStack)==0)
                    {
                        printf("ERROR: %s is unable to reach\n",$1.tokenID);
                        copyTokenInfo($$,s_table.table[$1.tokenID].info);
                    }
                    else
                        copyTokenInfo($$,s_table.table[$1.tokenID].info);
                }
                ;
const_exp:      INT_NUMBER      {$$=$1;}
                |REAL_NUMBER    {$$=$1;}
                |STR            {$$=$1;}
                |TRUE           {$$=$1;}
                |FALSE          {$$=$1;}
                ;
bool_expression:    '(' bool_expression ')'             {$$=$2;}
                    |expressions '<' expressions   
                    {
                    if($1.dType!=$3.dType)
                        yyerror("ERROR:bool_expression '<' type error");
                    }     
                    |expressions LESS_EQUAL expressions
                    {
                    if($1.dType!=$3.dType)
                        yyerror("ERROR:bool_expression '<' type error");
                    // $$=type_bool;
                    }     
                    |expressions '=' expressions
                    {
                    if($1.dType!=$3.dType)
                        yyerror("ERROR:bool_expression '<' type error");
                    // $$=type_bool;
                    }     
                    |expressions MORE_EQUAL expressions
                    {
                    if($1.dType!=$3.dType)
                        yyerror("ERROR:bool_expression '<' type error");
                    // $$=type_bool;
                    }     
                    |expressions '>' expressions
                    {
                    if($1.dType!=$3.dType)
                        yyerror("ERROR:bool_expression '<' type error");
                    // $$=type_bool;
                    }     
                    |expressions NOT_EQUAL expressions
                    {
                    if($1.dType!=$3.dType)
                        yyerror("ERROR:bool_expression '<' type error");
                    // $$=type_bool;
                    }     
                    |NOT expressions
                    {
                        // $$=type_bool;
                    }
                    |expressions AND expressions
                    {
                    if($1.dType!=$3.dType)
                        yyerror("ERROR:bool_expression '<' type error");
                    // $$=type_bool;
                    }     
                    |expressions OR expressions
                    {
                    if($1.dType!=$3.dType)
                        yyerror("ERROR:bool_expression '<' type error");
                    // $$.info.dType=type_bool;
                    }     
                    ;
function_invocation:    ID '(' ')' 
                        {
                            if(s_table.lookup($1.tokenID)==0)
                            {
                                yyerror("ERROR: function not declare");
                            }
                            else if(s_table.table[$1.tokenID].info.is_function)
                            {
                                printf("ERROR: %s is not function\n",$1.tokenID);
                                copyTokenInfo($$,s_table.table[$1.tokenID].info);
                            }
                            else
                            {
                                copyTokenInfo($$,s_table.table[$1.tokenID].info);
                            }
                        }
                        |ID '(' functionInputA functionInputB ')'
                        {
                            if(s_table.lookup($1.tokenID)==0)
                            {
                                printf("ERROR: function %s not declare\n",$1.tokenID);
                            }
                            else if(s_table.table[$1.tokenID].info.is_function)
                            {
                                printf("ERROR: %s is not function\n",$1.tokenID);
                                copyTokenInfo($$,s_table.table[$1.tokenID].info);

                            }
                            // else if(s_table.funcVarCorrect($1.tokenID,functionVariable)==0)
                            // {
                            //     printf("ERROR: function %s input error\n",$1);
                            //     copyTokenInfo($$,s_table.table[$1.tokenID].info);
                            // }
                            else
                            {
                                copyTokenInfo($$,s_table.table[$1.tokenID].info);
                            }
                        }
                        ;
functionInputA:     expressions
                    {
                        tokenInfo temp;
                        temp.dType=$1.dType;
                        temp.is_array=0;
                        functionVariable.push_back(temp);
                    }
                    ;
functionInputB:     functionInputB ',' expressions
                    {
                        tokenInfo temp;
                        temp.dType=$3.dType;
                        temp.is_array=0;
                        functionVariable.push_back(temp);
                    }
                    |
                    ;

conditional:    IF bool_expression THEN
                {
                    scopeStack.push(currentStack);
                    currentStack=++stackNumber;
                    s_table.insertStack(scopeStack.top(),currentStack);
                }
                contents
                ELSE
                content
                END IF
                {
                    if(scopeStack.empty())
                    {
                        currentStack=0;
                    }
                    else
                    {
                        currentStack=scopeStack.top();
                        scopeStack.pop();
                    }
                }
                |IF bool_expression THEN
                {
                    scopeStack.push(currentStack);
                    currentStack=++stackNumber;
                    s_table.insertStack(scopeStack.top(),currentStack);
                }
                contents
                END IF
                {
                    if(scopeStack.empty())
                    {
                        currentStack=0;
                    }
                    else
                    {
                        currentStack=scopeStack.top();
                        scopeStack.pop();
                    }
                }

loop:           LOOP
                {
                    scopeStack.push(currentStack);
                    currentStack=++stackNumber;
                    s_table.insertStack(scopeStack.top(),currentStack);

                }
                contents
                END LOOP
                {
                    if(scopeStack.empty())
                    {
                        currentStack=0;
                    }
                    else
                    {
                        currentStack=scopeStack.top();
                        scopeStack.pop();
                    }
                }
                |FOR ID ':' expressions  '.' '.' expressions
                {
                    if(s_table.lookup($2.tokenID)==0)
                    {
                        printf("ERROR: for loop %s not found\n",$2.tokenID);
                    }
                    if($4.dType!=$7.dType)
                    {
                        printf("ERROR: for loop range error\n");
                    }
                    scopeStack.push(currentStack);
                    currentStack=++stackNumber;
                    s_table.insertStack(scopeStack.top(),currentStack);
                }
                contents
                END FOR
                {
                    if(scopeStack.empty())
                    {
                        currentStack=0;
                    }
                    else
                    {
                        currentStack=scopeStack.top();
                        scopeStack.pop();
                    }
                }
                |FOR DECREASING ID ':' expressions  '.' '.' expressions
                {
                    if(s_table.lookup($3.tokenID)==0)
                    {
                        printf("ERROR: for loop %s not found\n",$3.tokenID);
                    }
                    if($5.dType!=$8.dType)
                    {
                        printf("ERROR: for loop range error\n");
                    }
                    scopeStack.push(currentStack);
                    currentStack=++stackNumber;
                    s_table.insertStack(scopeStack.top(),currentStack);
                }
                contents
                END FOR
                {
                    if(scopeStack.empty())
                    {
                        currentStack=0;
                    }
                    else
                    {
                        currentStack=scopeStack.top();
                        scopeStack.pop();
                    }
                } 

%%

void yyerror(char *msg)
{
    fprintf(stderr, "%s\n", msg);
}

#include "lex.yy.cpp"


int main(int argc,char **argv)
{
    /* open the source program file */
    if (argc != 2) {
        printf ("Usage: sc filename\n");
        exit(1);
    }
    yyin = fopen(argv[1], "r");         /* open input file */
    className=argv[1];
    className.replace(className.size()-3,3,"");
    java.open(className+".jasm");
    java<<"class "<<className<<"{"<<endl;

    /* perform parsing */
    if (yyparse() == 1)                 /* parsing */
        yyerror("Parsing error !");     /* syntax error */
    s_table.dump();
    java<<"}"<<endl;
    java.close();
}
