# 2023 Compiler Design
## How to compiler
`make`
## How to run
`./a.out {要測試的source code}`

## change log
新增codegen.hpp 用來生成 jasm
修改parser.y 的if else規則來修正第二個作業的錯誤
新增codegen fuction 位於parser.y內
新增index位於symbaltable用於儲存變數index
剩餘變更詳見.git