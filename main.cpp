#include"symbolStack.hpp"

using namespace std;

int main()
{
    symbolStack s;
    symbol aa;
    aa.identity = "zz";
    aa.info.dType = type_int;
    s.insert(aa);
}