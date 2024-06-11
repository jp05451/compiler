#ifndef SYMBOL_HPP
#define SYMBOL_HPP
#include <iostream>
#include <vector>
#include <string>

using namespace std;

struct data
{
    /* data */
    int int_data = 0;
    float real_data = 0.0;
    bool bool_data = false;
    vector<int> dymention;
    string string_data = "";
    vector<data> array_data;
};

// struct data &operator * (const struct data &a,const struct data &b)
// {
//     struct data d;
//     d.int_data=a.int_data*b.int_data;
//     d.int_data=a.real_data*b.real_data;
//     d.bool_data=a.bool_data*b.real_data;
//     return d;
// }

enum dataType
{
    INT_TYPE,
    REAL_TYPE,
    BOOL_TYPE,
    STRING_TYPE,
    CHAR_TYPE,
    NONE_TYPE
};

enum flag
{
    VARIABLE,
    CONSTANT,
    FUNC,
    ARRAY_FLAG,
    NONE_FLAG
};

dataType stringToType(string t)
{
    if (t == "INT")
        return INT_TYPE;
    if (t == "REAL")
        return REAL_TYPE;
    if (t == "BOOL")
        return BOOL_TYPE;
    if (t == "CHAR")
        return CHAR_TYPE;
    return NONE_TYPE;
}

class symbol
{
public:
    string id;
    int param_num = 0;
    struct data S_data;
    dataType S_type;
    flag S_flag;
    bool init = false;
    int index = -1;

    symbol(string id_)
    {
        id = id_;
    }
    symbol(){};

    ~symbol(){};

    bool operator==(string id_)
    {
        return this->id == id_;
    }

    bool isConst()
    {
        return S_flag == flag::CONSTANT;
    }
};

symbol *intConst(int value_)
{
    symbol *s = new symbol();
    s->S_data.int_data = value_;
    s->S_type = dataType::INT_TYPE;
    s->S_flag = flag::CONSTANT;
    return s;
}

symbol *realConst(float value_)
{
    symbol *s = new symbol();
    s->S_data.real_data = value_;
    s->S_type = dataType::REAL_TYPE;
    s->S_flag = flag::CONSTANT;
    return s;
}

symbol *boolConst(bool value_)
{
    symbol *s = new symbol();
    s->S_data.bool_data = value_;
    s->S_type = dataType::BOOL_TYPE;
    s->S_flag = flag::CONSTANT;
    return s;
}

symbol *stringConst(string *value_)
{
    symbol *s = new symbol();
    s->S_data.string_data = *value_;
    s->S_type = dataType::STRING_TYPE;
    s->S_flag = flag::CONSTANT;
    return s;
}

#endif