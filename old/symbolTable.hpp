#ifndef SYMBOLTABLE_HPP
#define SYMBOLTABLE_HPP
#include <vector>
#include <set>
#include <string>
#include <unordered_map>
#include <algorithm>
#include <iostream>
#include <iomanip>
#include <stack>

#define MAX_LINE_LENG 256

using namespace std;

string typeString[] = {
    "int",
    "real",
    "string",
    "bool",
    "array",
    // function
    "function"};

enum master_type
{
    is_normal,
    is_arr,
    is_constant,
    is_func
};

enum dataType
{
    type_int,
    type_real,
    type_string,
    type_bool,
    type_array,
    // funcion
    type_function,
    type_null

};

typedef struct funcVar
{
    string varID;
    dataType funcVarType;
    bool isArray;
} funcVar;

bool isNumeric(std::string const &str)
{
    auto it = str.begin();
    while (it != str.end() && std::isdigit(*it))
    {
        it++;
    }
    return !str.empty() && it == str.end();
}

class functionData
{
public:
    int varNumber = 0;
    vector<dataType> functionVar;
};

class symbolData
{
public:
    dataType type;
    master_type masterType;
    vector<int> stackNum;

    string stringVal;
    double realVal;
    functionData fData;
};

class symbolTable
{
public:
    symbolTable() {}
    ~symbolTable() {}
    void creat();
    bool lookup(const string &symbol);
    void insert(const string, const dataType, master_type, int);
    void insertStack(int, int);
    bool canAccess(const string &, int);
    bool funcVarCorrect(string funcName, vector<funcVar> &inputVar);
    void dump();
    // dataType getType(const string &, bool);

    unordered_map<string, symbolData> table;
};

void symbolTable::creat() {}

bool symbolTable::lookup(const string &symbol)
{
    unordered_map<string, symbolData>::iterator got = table.find(symbol);
    if (got == table.end())
        return 0;
    else
        return 1;
}

void symbolTable::insert(const string symbol, const dataType _type, master_type _masterType, int _stackNum)
{
    if (lookup(symbol) != 0)
    {
        cout << " ERROR: symbolTable insert " << symbol << " redefine" << endl;
        return;
    }
    table[symbol].type = _type;
    table[symbol].masterType = _masterType;
    table[symbol].stackNum.push_back(_stackNum);
    // insertStack(symbol, scopeStack.top(), _stackNum);
    cout << symbol << " is inserted in stack " << _stackNum << endl;
}

void symbolTable::insertStack(int lastStack, int currentStack)
{
    for (auto &eachSymbol : table)
    {
        if (eachSymbol.second.stackNum[0] != 0)
        // the symbol is not global
        {
            vector<int>::iterator canBeAccess = find(eachSymbol.second.stackNum.begin(), eachSymbol.second.stackNum.end(), lastStack);

            // the input stack can access this symbol in last stack
            if (canBeAccess != eachSymbol.second.stackNum.end())
            {
                eachSymbol.second.stackNum.push_back(currentStack);
                cout<<eachSymbol.first <<" can be access at stack "<<currentStack<<endl;
            }
        }
    }
}

void symbolTable::dump()
{
    int width = 20;
    cout << "==============================" << endl;
    cout << "Symbol Table:" << endl;

    cout << "ID"
         << "\t\t"
         << "type"
         << "\t\t"
         << "stack"
         << endl;

    for (auto &a : table)
    {
        cout << a.first << "\t\t";
        if (a.second.masterType == is_constant)
        {
            cout << "const ";
        }

        else if (a.second.masterType == is_func)
        {
            cout << "function ";
        }

        else if (a.second.masterType == is_arr)
        {
            cout << "array ";
        }
        else
            cout << "normal ";

        cout << typeString[a.second.type] << "\t\t";
        for (auto s : a.second.stackNum)
        {
            cout << s << " ";
        }
        cout << endl;
    }
}

bool symbolTable::canAccess(const string &symbol, int currentScope)
{
    if (lookup(symbol) == 0)
    {
        cout << "ERROR: " << symbol << " undeclare" << endl;
        return 0;
    }
    if (table[symbol].stackNum[0] == 0)
    {
        return 1;
    }
    vector<int>::iterator it = find(table[symbol].stackNum.begin(), table[symbol].stackNum.end(), currentScope);
    if (it != table[symbol].stackNum.end())
    {
        return 1;
    }
    return 0;
}

dataType intToType(int number)
{
    switch (number)
    {
    case 0:
        return type_int;
    case 1:
        return type_real;
    case 2:
        return type_string;
    case 3:
        return type_bool;
    }
    return type_null;
}

bool symbolTable::funcVarCorrect(string funcName, vector<funcVar> &inputVar)
{
    if(lookup(funcName)==0)
    {
        cout << "ERROR: funcName " << funcName << " undeclare" << endl;
        return 0;
    }
    if(inputVar.size()!=table[funcName].fData.varNumber)
        return 0;
    for (int i = 0; i < inputVar.size();i++)
    {
        if(table[funcName].fData.functionVar[i]!=inputVar[i].funcVarType)
            return 0;
    }
    return 1;
}

#endif