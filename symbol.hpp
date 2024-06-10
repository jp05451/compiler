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
    string string_data = "";
    vector<data> array_data;
};

enum dataType
{
    INT_TYPE,
    REAL_TYPE,
    BOOL_TYPE,
    STRING_TYPE,
    CHAR_TYPE,
    NONE_TYPE
};

enum dataFlag
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
    dataFlag S_flag;
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
        return S_flag == dataFlag::CONSTANT;
    }
};

#endif