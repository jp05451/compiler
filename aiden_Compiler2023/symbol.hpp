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
    string string_data = "";
    vector<data> array_data;
};


enum class type
{
    INT_TYPE,
    REAL_TYPE,
    BOOL_TYPE,
    STRING_TYPE,
    NONE
};

enum class flag
{
    VARIABLE,
    CONSTANT,
    FUNC,
    ARRAY_FLAG,
    NONE
};

class Symbol {
public:
    string id;
    int param_num = 0;
    data S_data;
    type S_type;
    flag S_flag;
    bool init = false;
    int index = -1;

    Symbol(string id_)
    {
        id = id_;
    }
    Symbol(){};
    
    ~Symbol(){};

    bool operator == (string id_)
    {
        return this->id == id_;
    }

    bool isConst()
    {
        return S_flag == flag::CONSTANT;
    }
};

Symbol *intConst(int value_)
{
    Symbol *s = new Symbol();
    s->S_data.int_data = value_;
    s->S_type = type::INT_TYPE;
    s->S_flag = flag::CONSTANT;
    return s;
}

Symbol *realConst(float value_)
{
    Symbol *s = new Symbol();
    s->S_data.real_data = value_;
    s->S_type = type::REAL_TYPE;
    s->S_flag = flag::CONSTANT;
    return s;
}

Symbol *boolConst(bool value_)
{
    Symbol *s = new Symbol();
    s->S_data.bool_data = value_;
    s->S_type = type::BOOL_TYPE;
    s->S_flag = flag::CONSTANT;
    return s;
}

Symbol *stringConst(string *value_)
{
    Symbol *s = new Symbol();
    s->S_data.string_data = *value_;
    s->S_type = type::STRING_TYPE;
    s->S_flag = flag::CONSTANT;
    return s;
}