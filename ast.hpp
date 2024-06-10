class ast
{
public:
    int nodeType;
    struct ast *left;
    struct ast *right;
    ~ast()
    {
        delete left;
        delete right;
        delete this;
    }
};