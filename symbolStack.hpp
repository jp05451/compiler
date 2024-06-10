#include "symbolTable.hpp"
#include <string>
#include <vector>
#pragma once

class symbolStack
{
public:
public:
    vector<SymbolTable> tables;
    symbolStack()
    {
        push();
    };
    ~symbolStack(){};
    void insert(string id)
    {
        if (lookup(id) == NULL)
            tables.back().insert(id);
    }
    void insert(string id, symbol symbol)
    {
        symbol.id = id;
        if (lookup(id) == NULL)
            tables.back().table.push_back(symbol);

        // if (!isGlobal(id))
        //     tables.back().table.back().index = tables.back().index++;
    }
    
    symbol *lookup(string id)
    {
        return tables.back().lookup(id);
    }

    symbol *global_lookup(string id)
    {
        for (vector<SymbolTable>::reverse_iterator it = tables.rbegin(); it != tables.rend(); ++it)
        {
            symbol *symbol = it->lookup(id);
            if (symbol != NULL)
                return symbol;
        }
        return NULL;
    }
    void push()
    {
        tables.push_back(SymbolTable());
    }
    void pop()
    {
        tables.pop_back();
    }
    void dump()
    {
        for (vector<SymbolTable>::iterator it = tables.begin(); it != tables.end(); ++it)
            it->dump();
            // cout << it << endl;
    }
    bool isGlobal()
    {
        cout << tables.size() << endl;
        return tables.size() == 1;
    }
    bool isGlobal(string id)
    {
        return tables[0].lookup(id) != NULL && (lookup(id) == NULL || tables.size() == 1);
    }
    int get_index(string id)
    {
        return global_lookup(id)->index;
    }
};

// ostream &operator<<(ostream &ostr, symbolStack s)
// {
//     for (int i = s.top; i >= 0; i--)
//     {
//         ostr << i << endl;
//         ostr << s.symbol_table[i] << endl;
//     }
//     return ostr;
// }