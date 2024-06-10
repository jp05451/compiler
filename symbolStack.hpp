#include "symbolTable.hpp"
#include "symbol.hpp"
#include <string>
#include <vector>
#pragma once

class symbolStack
{
public:
    symbolStack() { newTable(); }
    bool insert(const symbol &);
    symbol &search(string);
    void newTable();
    void removeTable();

    vector<symbolTable> symbol_table;
    size_t top = -1;
};
void symbolStack::newTable()
{
    symbolTable temp;
    symbol_table.push_back(temp);
    top++;
}
inline void symbolStack::removeTable()
{
    symbol_table.pop_back();
    top--;
}

bool symbolStack::insert(const symbol &s)
{
    symbol_table[top].insert(s);
}

inline symbol &symbolStack::search(string id)
{
    for (int i = top; i >= 0; i--)
    {
        if (symbol_table[i].isInTable(id))
        {
            return symbol_table[i].symbolMap[id];
        }
    }
}

ostream &operator << (ostream &ostr,symbolStack s)
{
    for (int i = s.top; i >= 0;i--)
    {
        ostr << i << endl;
        ostr << s.symbol_table[i] << endl;
    }
    return ostr;
}