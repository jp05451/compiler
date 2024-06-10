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
#include <vector>
#include "symbol.hpp"

using namespace std;

#define MAX_LINE_LENG 256
class symbolTable
{
public:
    ostream &operator<<(ostream &);
    string identity;

    bool insert(const symbol &);
    bool isInTable(string);
    void dump();

    unordered_map<string, symbol> symbolMap;
};

bool symbolTable::isInTable(string identity)
{
    unordered_map<string, symbol>::iterator it;
    it = symbolMap.find(identity);
    if (it != symbolMap.end())
        return true;
    return false;
}

bool symbolTable::insert(const symbol &s)
{
    symbolMap[s.identity] = s;
}

inline ostream &operator<<(ostream &ostr, const symbolTable &s)
{
    ostr << "ID" << "\t" << "info" << endl;
    for (auto &t : s.symbolMap)
    {
        ostr << t.first << t.second << endl;
    }
}

#endif