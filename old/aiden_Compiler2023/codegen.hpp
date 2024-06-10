#include <iostream>
#include <fstream>
#include "symboltable.hpp"
using namespace std;


class label
{
public:
  // count
  int Count;
  //flag
  int labelFlag;
  label(int input)
  {
    Count = input;
    labelFlag = -1;
  };

  ~label(){};
};

class LabelManager
{
private:
  int counts;
  vector<label> labelVector;

public:
  LabelManager()
  {
    counts = 0;
  }

  void pushNLable(int n)
  {
    label temp = label(counts);
    labelVector.push_back(temp);
    counts = counts + n;
  }

  void NLabel(int n)
  {
    labelVector.back().Count += n;
    counts = counts + n;
  }

  void popLabel()
  {
    labelVector.pop_back();
  }

  int takeLabel(int n)
  {
    int temp = labelVector.back().Count + n;
    return temp;
  }

  int getLable()
  {
    return counts++;
  }

  int getFlag()
  {
    return labelVector.back().labelFlag;
  }
};


LabelManager labelManager;

extern ofstream output;
extern string className;


enum class condition
{
  IFLT, //  <
  IFGT, //  >
  IFLE, //  <=
  IFGE, //  >=
  IFEE, //  ==
  IFNE, //
};

enum class op
{
  A_D_D,
  S_U_B,
  M_U_L,
  D_I_V,
  M_O_D,
  N_E_G,
  A_N_D,
  O_R,
  N_O_T,
};


// Initialize the output file
void G_init()
{
    output << "class " << className << "{" << endl;
}

// End the output file
void G_end()
{
    output << "}" << endl;
}

// Gen main function
void G_main()
{
  output << "\tmethod public static void main(java.lang.String[])"
     << "\n";
  output << "\tmax_stack 15"
     << "\n";
  output << "\tmax_locals 15"
     << "\n"
     << "\t{"
     << "\n";
}

// Function end
void G_main_end()
{
    output << "\t}" << endl;
}

// Dec global variable
void G_global_Var(string id)
{
    output << "\tfield static int " << id << endl;
}

// Dec global variable with value
void G_global_Var(string id, int value)
{
    output << "\tfield static int " << id << " = " << value << endl;
}

// Dec local variable
void G_local_Var(int index)
{
    output << "\t\tistore " << index << "\n";
}

// Dec local variable with value
void G_local_Var(int index, int value)
{
    output << "\t\tsipush " << value << "\n";
    output << "\t\tistore " << index << "\n";
}

// Declartion of put
void G_put_Dec()
{
  output << "\t\tgetstatic java.io.PrintStream java.lang.System.out" << endl;
}

// Body of put
void G_put(type idType)
{

  string type = "";
  switch (idType)
  {
  case type::INT_TYPE:
    type = "int";
    break;
  case type::STRING_TYPE:
    type = "java.lang.String";
    break;
  default:
    type = "int";
    break;
  }
  output << "\t\tinvokevirtual void java.io.PrintStream.print(" << type << ")\n";
}

// Method of skip
void G_skip()
{
  output << "\t\tgetstatic java.io.PrintStream java.lang.System.out" << endl;
  output << "\t\tinvokevirtual void java.io.PrintStream.println()\n";
}

// load const string
void G_const_Str(string input)
{
  output << "\t\tldc \"" << input << "\"" << endl;
}

// load const int
void G_const_Int(int input)
{
  output << "\t\tsipush " << input << endl;
}

// load const bool
void G_const_Bool(bool input)
{
    if(input)
        output << "\t\ticonst_1" << endl;
    else
        output << "\t\ticonst_0" << endl;
}

// result
void G_Result()
{
  output << "\t\tireturn"
     << "\n";
}

// return
void G_Return()
{
  output << "\t\treturn"
     << "\n";
}

// get global variable
void G_get_global_Var(string id)
{
  output << "\t\tgetstatic int " << className << "." << id << "\n";
}

// get local variable
void G_get_local_Var(int index)
{
  output << "\t\tiload " << index << "\n";
}

// operator
void G_Operator(op op)
{
  switch (op)
  {
  case op::N_E_G:
    output << "\t\tineg"
       << "\n";
    break;
  case op::M_U_L:
    output << "\t\timul"
       << "\n";
    break;
  case op::D_I_V:
    output << "\t\tidiv"
       << "\n";
    break;
  case op::A_D_D:
    output << "\t\tiadd"
       << "\n";
    break;
  case op::S_U_B:
    output << "\t\tisub"
       << "\n";
    break;
  case op::N_O_T: 
    output << "\t\tldc 1"
       << "\n"
       << "\t\tixor"
       << "\n";
    break;
  case op::A_N_D:
    output << "\t\tiand"
       << "\n";
    break;
  case op::O_R:
    output << "\t\tior"
       << "\n";
    break;
  case op::M_O_D:
    output << "\t\tirem"
       << "\n";
    break;
  }
}

// compare
void G_Compare(condition cond)
{
  output << "\t\tisub" << endl;
  switch (cond)
  {
  case condition::IFLT:
    output << "\t\tiflt";
    break;
  case condition::IFGT:
    output << "\t\tifgt";
    break;
  case condition::IFLE:
    output << "\t\tifle";
    break;
  case condition::IFGE:
    output << "\t\tifge";
    break;
  case condition::IFEE:
    output << "\t\tifeq";
    break;
  case condition::IFNE:
    output << "\t\tifne";
    break;
  }
  int label_1 = labelManager.getLable();
  int label_2 = labelManager.getLable();
  output << " L" << label_1 << "\n";
  output << "\t\ticonst_0" << "\n";
  output << "\t\tgoto L" << label_2 << "\n";
  output << "L" << label_1 << ":" << "\n";
  output << "\t\ticonst_1" << "\n";
  output << "L" << label_2 << ":" << "\n";
}

// function declaration start
void G_method_Start(Symbol info)
{
  output << "\tmethod public static ";
  output << ((info.S_type == type::NONE) ? "void" : "int");
  output << " " + info.id + "(";
  for (int i = 0; i < info.param_num; i++)
  {
    if (i != 0)
      output << ", ";
    output << "int";
  }
  output << ")"
     << "\n";
  output << "\tmax_stack 15"
     << "\n";
  output << "\tmax_locals 15"
     << "\n"
     << "\t{"
     << "\n";
}

// if start
void G_If_Start()
{
  labelManager.pushNLable(2);
  output << "\t\tifeq L" << labelManager.takeLabel(0) << endl;
}

// if else
void G_If_Else()
{
  output << "\t\tgoto L" << labelManager.takeLabel(1) << endl;
  output << "L" << labelManager.takeLabel(0) << ":" << endl;
}

// if end
void G_If_End()
{
  output << "L" << labelManager.takeLabel(0) << ":" << endl;
  labelManager.popLabel();
}

// if else end
void G_If_Else_End()
{
  output << "L" << labelManager.takeLabel(1) << ":" << endl;
  labelManager.popLabel();
}

// call function
void G_call_Func(Symbol info)
{
  output << "\t\tinvokestatic ";
  output << ((info.S_type == type::NONE) ? "void" : "int");
  output << " " + className + "." + info.id + "(";
  for (int i = 0; i < info.param_num; ++i)
  {
    if (i != 0)
      output << ", ";
    output << "int";
  }
  output << ")"
     << "\n";
}

// set global variable
void G_set_global_Var(string id)
{
  output << "\t\tputstatic int " << className << "." << id << "\n";
}

// set local variable
void G_set_local_Var(int index)
{
  output << "\t\tistore " << index << "\n";
}

// head of loop
void G_Loop_Start()
{

  labelManager.pushNLable(4);
  output << "L" << labelManager.takeLabel(0) << ":" << endl;
  
}

// end of loop
void G_Loop_End()
{
  output << "\t\tgoto L" << labelManager.takeLabel(labelManager.getFlag()) << endl;
  output << "L" << labelManager.takeLabel(3 + labelManager.getFlag()) << ":" << endl;
  labelManager.popLabel();
}

// when condition break
void G_When()
{
  labelManager.NLabel(1);
  output << "\t\tifne L" << labelManager.takeLabel(3 + labelManager.getFlag()) << endl;
}

// for with loacl variable
void G_For(int index, int value)
{
  G_get_local_Var(index);
  output << "\t\tsipush " << value << "\n";
}

// for with global variable
void G_For(string id, int value)
{
  G_get_global_Var(id);
  output << "\t\tsipush " << value << "\n";
}

// for body
void G_For_Body(string id)
{
  G_get_global_Var(id);
  G_const_Int(1);
  G_Operator(op::A_D_D);
  G_set_global_Var(id);
}