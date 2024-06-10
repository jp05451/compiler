#include <iostream>
#include <string>
#pragma once

using namespace std;

enum dataType
{
    type_int,
    type_real,
    type_char,
    type_none
};
enum dataType stringToType(string t)
{

    if(t== "INT")
        return type_int;
    if (t == "REAL")
        return type_real;
    if (t == "CHAR")
        return type_char;
    return type_none;}
class dataInfo
{
public:
    dataType dType;
    struct value
    {
        char charValue[100];
        int intValue;
        double realValue;
    } value;
};

ostream &operator<<(ostream &ostr, dataInfo info)
{
    ostr << info.dType << " ";
    if (info.dType == type_int)
    {
        ostr << info.value.intValue;
        return ostr;
    }
    if (info.dType == type_real)
    {
        ostr << info.value.realValue;
        return ostr;
    }
    if (info.dType == type_char)
    {
        ostr << info.value.charValue;
        return ostr;
    }
    return ostr;
}

class symbol
{
public:
    symbol(){};
    symbol(string id, dataType type)
    {
        identity = id;
        info.dType = type;
    }
    string identity;
    dataInfo info;
    template <class T>
    void setValue(const T &);
};

template <class T>
inline void symbol::setValue(const T &value)
{
    if (info.dType == "INT")
    {
        info.value.intValue = (int)value;
        return;
    }
    if (info.dType == "REAL")
    {
        info.value.intValue = (double)value;
        return;
    }
    if (info.dType == "CHAR")
    {
        info.value.intValue = (char)value;
        return;
    }
    if (info.dType == "BOOL")
    {
        info.value.intValue = (bool)value;
        return;
    }
}

ostream &operator<<(ostream &ostr, const symbol &s)
{
    ostr << s.identity << "\t" << s.info;
    return ostr;
}
