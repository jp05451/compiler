#include "symbol.hpp"
#include <fstream>

extern ofstream output;

enum op
{
    A_D_D,
    S_U_B,
    M_U_L,
    D_I_V
};

void G_op(op oper, symbol *a, symbol *b)
{
    // check if is array
    if (isArray(a) || isArray(b))
        return;

    if (a->isConst())
    {
        if (a->S_type == INT_TYPE)
            output << a->S_data.int_data;
        if (a->S_type == REAL_TYPE)
            output << a->S_data.real_data;
    }
    else
    {
        if (a->S_type == INT_TYPE)
            output << a->id;
        if (a->S_type == REAL_TYPE)
            output << a->id;
    }

    switch (oper)
    {
    case A_D_D:
        output << " + ";
        return;
    case S_U_B:
        output << " - ";
        return;
    case M_U_L:
        output << " * ";
        return;
    case D_I_V:
        output << " / ";
        return;
    }

    if (b->isConst())
    {
        if (a->S_type == INT_TYPE)
            output << b->S_data.int_data;
        if (a->S_type == REAL_TYPE)
            output << b->S_data.real_data;
    }
    else
    {
        if (a->S_type == INT_TYPE)
            output << b->S_data.int_data;
        if (a->S_type == REAL_TYPE)
            output << b->S_data.real_data;
        // if (a->S_type == INT_TYPE)
        //     output << b->id;
        // if (a->S_type == REAL_TYPE)
        //     output << b->id;
    }
}

void G_print(symbol *s)
{
    output << "printf(\"";
    if (!isArray(s))
    {
        if (s->S_type == INT_TYPE)
        {
            output << s->S_data.int_data;
        }
        if (s->S_type == REAL_TYPE)
        {
            output << s->S_data.real_data;
        }
    }
    else if (isArray(s))
    {
        if (s->S_type == INT_TYPE)
            // for (auto a : s->S_data.array_data)
            for (int i = 0; i < s->S_data.array_data.size(); i++)
            {
                output << s->S_data.array_data[i].int_data;
                if (i != s->S_data.array_data.size() - 1)
                    output << ",";
            }
        if (s->S_type == REAL_TYPE)
            // for (auto a : s->S_data.array_data)
            for (int i = 0; i < s->S_data.array_data.size(); i++)
            {
                output << s->S_data.array_data[i].real_data;
                if (i != s->S_data.array_data.size() - 1)
                    output << ",";
            }
    }
    output << "\");" << endl;
}

void G_println(symbol *s)
{
    output << "printf(\"";
    if (!isArray(s))
    {
        if (s->S_type == INT_TYPE)
        {
            output << s->S_data.int_data;
        }
        if (s->S_type == REAL_TYPE)
        {
            output << s->S_data.real_data;
        }
    }
    else if (isArray(s))
    {
        if (s->S_type == INT_TYPE)
            // for (auto a : s->S_data.array_data)
            for (int i = 0; i < s->S_data.array_data.size(); i++)
            {
                output << s->S_data.array_data[i].int_data;
                if (i != s->S_data.array_data.size() - 1)
                    output << ",";
            }
        if (s->S_type == REAL_TYPE)
            // for (auto a : s->S_data.array_data)
            for (int i = 0; i < s->S_data.array_data.size(); i++)
            {
                output << s->S_data.array_data[i].real_data;
                if (i != s->S_data.array_data.size() - 1)
                    output << ",";
            }
    }
    output << "\\n\");" << endl;
}

void G_variable(symbol *s)
{
    if (s->id == "" || s->S_flag == CONSTANT)
    {
        return;
    }
    if (s->S_type == INT_TYPE && !isArray(s))
    {
        output << "int " << s->id << " = " << s->S_data.int_data << ";" << endl;
        return;
    }
    if (s->S_type == REAL_TYPE && !isArray(s))
    {
        output << "float " << s->id << " = " << s->S_data.real_data << ";" << endl;
        return;
    }
}

void G_main()
{
    output << "#include<stdio.h>" << endl
           << endl;
    output << "int main()" << endl;
    output << "{" << endl;
}

// End the output file
void G_end()
{
    output << "}" << endl;
}