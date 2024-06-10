#ifndef SYMBOLTABLE_HPP
#define SYMBOLTABLE_HPP
#include <vector>
#include <set>
#include <string>
#include <algorithm>
#include <iostream>
#include "symbol.hpp"

using namespace std;

#define MAX_LINE_LENG 256
class SymbolTable
{
public:
    vector<symbol> table;
    int index = -1;
    symbol *lookup(string id)
    {
        vector<symbol>::iterator it = find(table.begin(), table.end(), id);
        if (it != table.end())
            return &(*it);
        else
            return NULL;
    }
    void insert(symbol &s)
    {
        table.push_back(s);
    }
    void insert(string id)
    {
        if (lookup(id) == NULL)
            table.push_back(symbol(id));
    }
    void dump()
    {
        for (vector<symbol>::iterator it = table.begin(); it != table.end(); ++it)
            cout << it->id << "\t" << it->index << endl;
    }
};

#endif