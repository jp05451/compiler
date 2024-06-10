#include "ast.hpp"

ast *ast::newAst(int nodetype, ast *l, ast *r)
{
    ast *returnAST = new ast;
    returnAST->nodeType = nodetype;
    returnAST->left = l;
    returnAST->right = r;

    return returnAST;
}

ast *ast::newNum(double d)
{
    ast *a = new ast;
    a->left = nullptr;
    a->right = nullptr;
    a->data.doubleVal = d;
    return a;
}

double ast::eval()
{
    if (nodeType == '+')
        return left->eval() + right->eval();
    if (a->nodeType == '-')
        return left->eval() - right->eval();
    if (a->nodeType == '*')
        return left->eval() * right->eval();
    if (a->nodeType == '/')
        return left->eval() / right->eval();

    if (left == nullptr && right == nullptr)
    {
        return data.doubleVal;
    }
}
