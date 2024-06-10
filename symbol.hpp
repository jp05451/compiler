#include <iostream>
#include <string>
#pragma once

using namespace std;

enum dataType
{
    type_int,
    type_real,
    type_char,
    type_string
};

class dataInfo
{
public:
    string dType;
    struct value
    {
        char charValue;
        int intValue;
        double doubleValue;
    } value;
};

ostream &operator<<(ostream &ostr, dataInfo info)
{
    ostr << "type " << info.dType << " value: " << info.value.intValue << " " << info.value.doubleValue << info.value.charValue;
    return ostr;
}

class symbol
{
public:
    string identity;
    dataInfo info;
    // symbol &operator=(const symbol &s)
    // {
    //     identity = s.identity;
    //     info = s.info;
    // }
};

ostream &operator<<(ostream &ostr, const symbol &s)
{
    ostr << s.identity << "\t" << s.info;
    return ostr;
}
