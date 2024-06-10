class numberVal
{
public:
    int intVal;
    double doubleVal;
};

class ast
{
public:
    double nodeType;
    numberVal data;
    struct ast *left = nullptr;
    struct ast *right = nullptr;
    struct ast *newAst(int nodetype, struct ast *l, struct ast *r);
    struct ast *newNum(double d);
    double eval(); /* evaluate an AST */
    ~ast()
    {
        delete left;
        delete right;
    }
};