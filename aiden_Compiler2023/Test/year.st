% This program checks if a given year is a leap year

var year : int
var isLeapYear : bool := false

put "Enter a year: "
get year

if year mod 4 = 0 then
    if year mod 100 = 0 then
        if year mod 400 = 0 then
            isLeapYear := true
        end if
    else
        isLeapYear := true
    end if
end if

if isLeapYear then
    put year
    put " is a leap year."
else
    put year
    put " is not a leap year."
end if
