{% Sigma.st
 %
 % Compute sum = 1 + 2 + ... + n
 %}

% constant and variable declarations
const n: int := 10
var sum: int
var index: int

% main statements
sum := 0
for index: 1 .. n 
  sum := sum + index
end for
put "The result is "
put sum
skip

