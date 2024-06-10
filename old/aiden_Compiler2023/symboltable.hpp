#include <vector>
#include <algorithm>
#include "symbol.hpp"

using namespace std;

class SymbolTable {
    public:
        vector<Symbol> table;
        int index = 0;
        SymbolTable(){};
        ~SymbolTable(){};
        void insert(string id)
        {
            if(lookup(id)==NULL)
                table.push_back(Symbol(id));
        }
        void insert(Symbol &symbol)
        {
            
            table.push_back(symbol);
        }
        Symbol *lookup(string id)
        {
            vector<Symbol>::iterator it = find(table.begin(), table.end(), id);
            if(it != table.end())
                return &(*it);
            else
                return NULL;
        }
        void dump()
        {
            for(vector<Symbol>::iterator it = table.begin(); it != table.end(); ++it)
                cout << it->id << "\t" << it->index << endl;
        }
};

class symboltables {
    public:
        vector<SymbolTable> tables;
        symboltables(){
            push();
        };
        ~symboltables(){};
        void insert(string id)
        {
            if(lookup(id) == NULL)
                tables.back().insert(id);
        }
        void insert(string id, Symbol symbol)
        {
            symbol.id = id;
            if(lookup(id) == NULL)
                tables.back().table.push_back(symbol);
            
            if(!isGlobal(id))
                tables.back().table.back().index = tables.back().index++;
        }
        Symbol *lookup(string id)
        {
            return tables.back().lookup(id);
        }
        Symbol *global_lookup(string id)
        {
            for(vector<SymbolTable>::reverse_iterator it = tables.rbegin(); it != tables.rend(); ++it)
            {
                Symbol *symbol = it->lookup(id);
                if(symbol != NULL)
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
            for(vector<SymbolTable>::iterator it = tables.begin(); it != tables.end(); ++it)
                it->dump();
        }
        bool isGlobal()
        {
            cout<<tables.size()<<endl;
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