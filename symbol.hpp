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
    dataType dType;
    union value
    {
        char charValue; 
        int intValue;
        double doubleValue;
    };
};

class symbol
{
public:
    string identity;
    dataInfo info;
    symbol &operator=(const symbol &s)
    {
        identity = s.identity;
        info = s.info;
    }
};
