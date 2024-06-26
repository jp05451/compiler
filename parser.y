%{
#include<fstream>
#include "lex.yy.cpp"
#include "symbolStack.hpp"
#include "codegen.hpp"

#define Trace(t)        printf(t)
void yyerror(string msg)
{
    cerr << "yyerror: line " << linenum << ": " << msg << endl;
}
symbolStack symStack;
vector<double> arrayData;
ofstream output;
%}

%union { 
    class symbol *sym;
    double real_value;
    // enum dataType d;
    char dType[10];
    char identity[256];
    char string[256];
}


%type <sym> expressions factor term  arrayValue
/* %type <real_value> bool_expression */
%type <sym> const_exp
%type <dType> Type
%type <sym> dymention


/* tokens */

%token <real_value> INT_VALUE REAL_VALUE TRUE FALSE
%token <identity> ID 
%token <string> STR // define
%token VAR VAL // define
%token BOOL CHAR INT REAL CLASS // data type
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
                    if(symStack.lookup($2)!=NULL)
                    {
                        yyerror("ERROR: duplicate declaration");
                        YYABORT;
                    }
                    symbol s($2);
                    s.S_type=stringToType($4);
                    symStack.insert($2,s);

                    G_variable(&s);
                }
                |VAR ID ':' Type '=' expressions ';'
                {
                    if(symStack.lookup($2)!=NULL)
                    {
                        yyerror("ERROR: duplicate declaration");
                        YYABORT;
                    }
                    symbol s($2);
                    s.S_type = stringToType($4);
                    s.S_data = $6->S_data;
                    s.init = true;
                    if(typeMismatch(&s,$6))
                    {
                        cout<<"WARRNING: type mismatch"<<endl;
                        if(s.S_type==dataType::REAL_TYPE)
                        {
                            s.S_data.real_data = $6->S_data.int_data;
                        }
                        else if(s.S_type==INT_TYPE)
                        {
                            s.S_data.int_data = $6->S_data.real_data;
                        }
                    }

                    symStack.insert($2,s);

                    G_variable(&s);
                }
                |array
                ;

constant:       VAL ID ':' Type '=' expressions ';'
                {
                    if(symStack.lookup($2)!=NULL)
                    {
                        yyerror("ERROR: duplicate declaration");
                        YYABORT;
                    }
                    symbol s($2);
                    s.S_type=stringToType($4);
                    s.S_data.real_data=$6->S_data.real_data;
                    s.S_flag=CONSTANT;
                    symStack.insert($2,s);
                    delete $6;
                }
                // const array declare
                |VAL ID ':' Type dymention '=' '{' arrayValue '}' ';'
                {
                    if(symStack.lookup($2)!=NULL)
                    {
                        yyerror("ERROR: duplicate declaration");
                        YYABORT;
                    }
                    symbol s($2);
                    s.S_type=stringToType($4);
                    s.S_flag=ARRAY_FLAG;
                    s.S_data.dymention=$5->S_data.dymention;
                    s.S_data.array_data=$8->S_data.array_data;
                    int totalDymention=0;
                    for (auto& n : s.S_data.dymention)
                        totalDymention += n; //calculate total dymentions;
                    
                    if(totalDymention < s.S_data.array_data.size())
                    {
                        yyerror("ERROR: too many dimensions");
                        YYABORT;
                    }
                    else
                    {
                        s.S_data.array_data.resize(s.S_data.dymention[0]);
                    }
                    symStack.insert($2,s);
                    delete $5;
                    delete $8;
                }
                ;

array:      VAR ID ':' Type dymention '=' '{' arrayValue '}' ';'
            {
                
                if(symStack.lookup($2)!=NULL)
                {
                    yyerror("ERROR: duplicate declaration");
                    YYABORT;
                }
                symbol s($2);
                s.S_type=stringToType($4);
                s.S_flag=ARRAY_FLAG;
                s.S_data.dymention=$5->S_data.dymention;

                if(typeMismatch(&s,$8))
                {
                    cout<<"WARRNING: type mismatch"<<endl;
                    if(s.S_type==INT_TYPE)
                    {
                        for(int i=0;i<$8->S_data.array_data.size();i++)
                        {
                            $8->S_data.array_data[i].int_data=$8->S_data.array_data[i].real_data;
                        }
                    }

                    if(s.S_type==REAL_TYPE)
                    {
                        for(int i=0;i<$8->S_data.array_data.size();i++)
                        {
                            $8->S_data.array_data[i].real_data=$8->S_data.array_data[i].int_data;
                            // cout<<$8->S_data.array_data[i].int_data<<endl;
                        }
                    }

                }

                // offset the array
                if(s.S_data.dymention.size()==2)
                {
                    s.S_data.array_data.resize(s.S_data.dymention[0]);
                    for(int i=0;i<s.S_data.dymention[0];i++)
                    {
                        s.S_data.array_data[i].array_data.resize(s.S_data.dymention[1]);
                        for(int j=0;j<s.S_data.dymention[1];j++)
                        {
                            s.S_data.array_data[i].array_data[j]=$8->S_data.array_data[i*s.S_data.dymention[1]+j];
                            // cout<<s.S_data.array_data[i].array_data[j].int_data<<" ";
                        }
                        // cout<<endl;
                    }
                }
                else
                    s.S_data.array_data=$8->S_data.array_data;

                
                //calculate total dymentions;
                int totalDymention=0;
                for (auto& n : s.S_data.dymention)
                    totalDymention += n;
                
                // check size leagle
                if(totalDymention < s.S_data.array_data.size())
                {
                    yyerror("ERROR: too many dimensions");
                    YYABORT;
                }
                else 
                {
                    // fill the array 0
                    s.S_data.array_data.resize(s.S_data.dymention[0]);
                }

                

                symStack.insert($2,s);
                
                delete $5;
                delete $8;
            }
            |VAR ID ':' Type dymention ';'
            {
                if(symStack.lookup($2)!=NULL)
                {
                    yyerror("ERROR: duplicate declaration");
                    YYABORT;
                }
                symbol s($2);
                s.S_type=stringToType($4);
                s.S_flag=ARRAY_FLAG;
                s.S_data.dymention=$5->S_data.dymention;
                symStack.insert($2,s);
                delete $5;
            }
            ;

dymention:  '[' INT_VALUE ']'
            {
                symbol *s = new symbol;
                s->S_data.dymention.push_back((int)$2);
                $$ = s;
            }
            |'[' INT_VALUE ']' '[' INT_VALUE ']'
            {
                symbol *s = new symbol;
                s->S_data.dymention.push_back($2);
                s->S_data.dymention.push_back($5);
                $$ = s;
            }
            ;

arrayValue: expressions
            {
                symbol *s = new symbol;
                s = $1;
                s->S_flag = ARRAY_FLAG;
                s->S_data.array_data.push_back($1->S_data);
                // delete $1;
                $$ = s;

            }
            |arrayValue ',' expressions
            {
                if($1->S_type != $3->S_type)
                {
                    yyerror("type mismatch");
                    YYABORT;
                }
                $1->S_data.array_data.push_back($3->S_data);
                $$ = $1;
            }
            /* |'{' arrayValue '}'
            |'{' arrayValue '}' ',' arrayValue */
            ;

functionDeclare:    FUNCTION ID '(' parameter ')' ':' Type
                    '{'
                        statments
                        RETURN expressions ';'
                    '}'
                    |FUNCTION MAIN '(' parameter ')'
                    {
                        G_main();
                    }
                    '{'
                        statments
                    {
                        G_end();
                    }
                    '}'
                    ;
                    

parameter:  ID ':' Type
            |parameter ',' ID ':' Type
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
            {
                symbol *s=symStack.global_lookup($1);
                if(s==NULL)
                {
                    yyerror("ID not defined");
                    YYABORT;
                }
                else
                {
                    s->S_data = $3->S_data;
                }
            }
            ;

print:      PRINT '(' expressions ')' ';' 
            {
                if(!isArray($3))
                {
                    if($3->S_type == INT_TYPE)
                    {
                        cout<<$3->S_data.int_data;
                    }
                    if($3->S_type == REAL_TYPE)
                    {
                        cout<<$3->S_data.real_data;
                    }
                }
                else if(isArray($3))
                {
                    if($3->S_type == INT_TYPE)
                        for(auto a:$3->S_data.array_data)
                        {
                            cout<<a.int_data<<",";
                        }
                    if($3->S_type == REAL_TYPE)
                        for(auto a:$3->S_data.array_data)
                        {
                            cout<<a.real_data<<",";
                        }
                }
                G_print($3);
            }
            |PRINTLN '(' expressions ')' ';'
            {
                if($3->S_flag != flag::ARRAY_FLAG)
                {
                    if($3->S_type == INT_TYPE)
                        cout<<$3->S_data.int_data;
                    if($3->S_type == REAL_TYPE)
                        cout<<$3->S_data.real_data;
                }
                else if($3->S_flag == flag::ARRAY_FLAG)
                {
                    if($3->S_type == INT_TYPE)
                        for(auto a:$3->S_data.array_data)
                            cout<<a.int_data;
                    if($3->S_type == REAL_TYPE)
                        for(auto a:$3->S_data.array_data)
                            cout<<a.real_data;
                }
                cout<<endl;
                G_println($3);
            }
            |PRINT '(' STR ')' ';'
            {
                G_print($3);
                cout<<$3;
            }
            |PRINTLN '(' STR ')' ';'
            {
                G_print(strcat($3,"\\n"));
                cout<<$3<<endl;
            }
            ;

block:      '{'
            {
                symStack.push();
                output<<"{"<<endl;
            }
                statments
            '}'
            {
                symStack.dump();
                symStack.pop();
                output<<"}"<<endl;
            }


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

expressions:    factor {$$ = $1;}
                |expressions '+' factor 
                {

                    /* type check */
                    if(typeMismatch($1,$3))
                    {
                        cout << "WARNING: type mismatch" << endl;

                        // yyerror("type mismatch");
                        // YYABORT;
                    }
                    //  not array
                    if(!isArray($1) && !isArray($3))
                    {
                        // int int 
                        if($1->S_type == dataType::INT_TYPE && $3->S_type == dataType::INT_TYPE)
                                $$ = intConst($1->S_data.int_data + $3->S_data.int_data);
                        // real int
                        else if($1->S_type == dataType::REAL_TYPE && $3->S_type == dataType::INT_TYPE)
                                $$ = realConst($1->S_data.real_data + $3->S_data.int_data);
                        //int real
                        else if($1->S_type == dataType::INT_TYPE && $3->S_type == dataType::REAL_TYPE)
                                $$ = realConst($1->S_data.int_data + $3->S_data.real_data);
                        // real real
                        else if($1->S_type == dataType::REAL_TYPE && $3->S_type == dataType::REAL_TYPE)
                                $$ = realConst($1->S_data.real_data + $3->S_data.real_data);
                        else
                                yyerror("operator error");
                    }
                    //  is array
                    else if(isArray($1) && isArray($1))
                    {
                        // dymention check
                        if($1->S_data.array_data.size() != $3->S_data.array_data.size())
                        {
                            yyerror("dymention mismatch");
                            YYABORT;
                        }
                        else
                        {
                            // int array
                            if($1->S_type == dataType::INT_TYPE)
                            {
                                symbol *result=new symbol;
                                result->S_flag = ARRAY_FLAG;
                                result->S_type = REAL_TYPE;
                                result->S_data.array_data.resize($1->S_data.array_data.size());
                                for(int i=0;i<$1->S_data.array_data.size();i++)
                                {
                                    int a=$1->S_data.array_data[i].int_data;
                                    int b=$3->S_data.array_data[i].int_data;
                                    result->S_data.array_data[i].int_data=a+b;
                                }
                                $$ = result;
                            }

                            // double array
                            else if($1->S_type == dataType::REAL_TYPE)
                            {
                                symbol *result=new symbol;
                                result->S_flag = ARRAY_FLAG;
                                result->S_type = REAL_TYPE;
                                result->S_data.array_data.resize($1->S_data.array_data.size());
                                for(int i=0;i<$1->S_data.array_data.size();i++)
                                {
                                    double a=$1->S_data.array_data[i].real_data;
                                    double b=$3->S_data.array_data[i].real_data;
                                    result->S_data.array_data[i].real_data=a+b;
                                }
                                $$ = result;
                            }
                        }
                    }
                    else
                    {
                        yyerror("operator error");
                        YYABORT;
                    }
                    // cout <<"Reduce exp + exp"<<endl;
                }
                |expressions '-' factor
                {
                   /* type check */
                    if($1->S_type != $3->S_type)
                    {
                        cout << "WARNING:type mismatch" << endl;
                        // yyerror("type mismatch");
                        // YYABORT;
                    }
                    //  not array
                    if(!isArray($1) && !isArray($3))
                    {
                        // int int 
                        if($1->S_type == dataType::INT_TYPE && $3->S_type == dataType::INT_TYPE)
                                $$ = intConst($1->S_data.int_data - $3->S_data.int_data);
                        // real int
                        else if($1->S_type == dataType::REAL_TYPE && $3->S_type == dataType::INT_TYPE)
                                $$ = realConst($1->S_data.real_data - $3->S_data.int_data);
                        //int real
                        else if($1->S_type == dataType::INT_TYPE && $3->S_type == dataType::REAL_TYPE)
                                $$ = realConst($1->S_data.int_data - $3->S_data.real_data);
                        // real real
                        else if($1->S_type == dataType::REAL_TYPE && $3->S_type == dataType::REAL_TYPE)
                                $$ = realConst($1->S_data.real_data - $3->S_data.real_data);
                        else
                                yyerror("operator error");
                    }

                    //  is array
                    else if(isArray($1) && isArray($1))
                    {
                        // dymention check
                        if($1->S_data.array_data.size() != $3->S_data.array_data.size())
                        {
                            yyerror("dymention mismatch");
                            YYABORT;
                        }
                        else
                        {
                            // int array
                            if($1->S_type == dataType::INT_TYPE)
                            {
                                symbol *result=new symbol;
                                result->S_flag = ARRAY_FLAG;
                                result->S_type = REAL_TYPE;
                                result->S_data.array_data.resize($1->S_data.array_data.size());
                                for(int i=0;i<$1->S_data.array_data.size();i++)
                                {
                                    int a=$1->S_data.array_data[i].int_data;
                                    int b=$3->S_data.array_data[i].int_data;
                                    result->S_data.array_data[i].int_data=a-b;
                                }
                                $$ = result;
                            }
                            // double array
                            else if($1->S_type == dataType::REAL_TYPE)
                            {
                                symbol *result=new symbol;
                                result->S_flag = ARRAY_FLAG;
                                result->S_type = REAL_TYPE;
                                result->S_data.array_data.resize($1->S_data.array_data.size());
                                for(int i=0;i<$1->S_data.array_data.size();i++)
                                {
                                    double a=$1->S_data.array_data[i].real_data;
                                    double b=$3->S_data.array_data[i].real_data;
                                    result->S_data.array_data[i].real_data=a-b;
                                }
                                $$ = result;
                            }
                        }
                    }
                    else
                    {
                        yyerror("operator error");
                        YYABORT;
                    }
                }
                ;

factor:         term    {$$ = $1;}
                |factor '*' term
                {
                    /* type check */
                    if($1->S_type != $3->S_type)
                    {
                        // yyerror("ERROR: type mismatch");
                        // YYABORT;
                        cout << "WARNING:type mismatch" << endl;
                    }

                    // not array
                    if(!isArray($1) && !isArray($3))
                    {
                        // int int 
                        if($1->S_type == dataType::INT_TYPE && $3->S_type == dataType::INT_TYPE)
                                $$ = intConst($1->S_data.int_data * $3->S_data.int_data);
                        // real int
                        else if($1->S_type == dataType::REAL_TYPE && $3->S_type == dataType::INT_TYPE)
                                $$ = realConst($1->S_data.real_data * $3->S_data.int_data);
                        //int real
                        else if($1->S_type == dataType::INT_TYPE && $3->S_type == dataType::REAL_TYPE)
                                $$ = realConst($1->S_data.int_data * $3->S_data.real_data);
                        // real real
                        else if($1->S_type == dataType::REAL_TYPE && $3->S_type == dataType::REAL_TYPE)
                                $$ = realConst($1->S_data.real_data * $3->S_data.real_data);
                        else
                                yyerror("operator error");
                    }
                    else if($1->S_flag == flag::ARRAY_FLAG && $3->S_flag == flag::ARRAY_FLAG)
                    {
                        // dymention check
                        if($1->S_data.array_data.size() != $3->S_data.array_data.size())
                        {
                            yyerror("dymention mismatch");
                            YYABORT;
                        }
                        else
                        {
                            if($1->S_type == dataType::INT_TYPE)
                            {
                                int sum=0;
                                for(int i=0;i<$1->S_data.array_data.size();i++)
                                {
                                    sum += $1->S_data.array_data[i].int_data * $3->S_data.array_data[i].int_data;
                                    $$ = intConst(sum);
                                }
                            }
                            else if($1->S_type == dataType::REAL_TYPE)
                            {
                                cout<<"REAL"<<endl;
                                double sum=0;
                                for(int i=0;i<$1->S_data.array_data.size();i++)
                                {
                                    sum += $1->S_data.array_data[i].real_data * $3->S_data.array_data[i].real_data;
                                    $$ = realConst(sum);
                                }
                            }
                        }
                    }
                    else
                    {
                        yyerror("operator error");
                        YYABORT;
                    }
                }
                |factor '/' term 
                {
                    /* type check */
                    if($1->S_type != $3->S_type)
                    {
                        // yyerror("ERROR: type mismatch");
                        // YYABORT;
                        cout << "WARNING:type mismatch" << endl;
                    }

                    // not array
                    if(!isArray($1) && !isArray($3))
                    {
                        // int int 
                        if($1->S_type == dataType::INT_TYPE && $3->S_type == dataType::INT_TYPE)
                                $$ = intConst($1->S_data.int_data / $3->S_data.int_data);
                        // real int
                        else if($1->S_type == dataType::REAL_TYPE && $3->S_type == dataType::INT_TYPE)
                                $$ = realConst($1->S_data.real_data / $3->S_data.int_data);
                        //int real
                        else if($1->S_type == dataType::INT_TYPE && $3->S_type == dataType::REAL_TYPE)
                                $$ = realConst($1->S_data.int_data / $3->S_data.real_data);
                        // real real
                        else if($1->S_type == dataType::REAL_TYPE && $3->S_type == dataType::REAL_TYPE)
                                $$ = realConst($1->S_data.real_data / $3->S_data.real_data);
                        else
                                yyerror("operator error");
                    }
                
                }
                ;

term:           '(' expressions ')' {$$ = $2;}
                |ID { $$ = symStack.global_lookup($1); }
                |ID '[' INT_VALUE ']'
                {
                    symbol *s = symStack.global_lookup($1);
                    if( s == NULL)
                    {
                        yyerror("ID not defined");
                        YYABORT;
                    }
                    if( s->S_flag != flag::ARRAY_FLAG)
                    {
                        yyerror("operator error");
                        YYABORT;
                    }
                    symbol term;
                    term.S_data = s->S_data.array_data[(int)$3];
                }
                |'-' expressions %prec NEGATIVE
                {
                    if($2->S_type == dataType::INT_TYPE)
                        $$ = intConst(-$2->S_data.int_data);
                    else if($2->S_type == dataType::REAL_TYPE)
                            $$ = realConst(-$2->S_data.real_data);
                    else
                            yyerror("operator error");
                }
                |const_exp {$$ = $1;}
                /* |functionCall */
                ;


functionCall:   ID '(' arguments ')';

arguments:      expressions
                |arguments ',' expressions
                ;

const_exp:      INT_VALUE { $$=intConst($1);}
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

/* void yyerror(char *msg)
{
    fprintf(stderr, "%s\n", msg);
} */


int main(int argc,char **argv)
{
    /* open the source program file */
    if (argc != 2) {
        printf ("Usage: sc filename\n");
        exit(1);
    }
    yyin = fopen(argv[1], "r");         /* open input file */
    
    string outputFile="output.c";
    /* for(int i=0;i<argc;i++)
    {
        if(strcmp(argv[i],"-o") == 0)
        {
            outputFile=argv[++i];
            outputFile+=".c";
        }
    }
    cout<<outputFile<<endl; */
    output.open(outputFile);


    /* perform parsing */
    if (yyparse() == 1)                 /* parsing */
        yyerror((char *)"Parsing error !");     /* syntax error */
    symStack.dump();
    output.close();
    system("gcc output.c -o output");
}
