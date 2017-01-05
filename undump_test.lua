local undump = require 'see.undump'
local bit = require 'bit32'

local cases = {
    {tostring(undump(undump)), '(str_or_function)'},
    {tostring(undump(function() end)), '()'},
    {tostring(undump(function(a, b, c) end)), '(a, b, c)'},
    {tostring(undump(function(a, b, ...) end)), '(a, b, ...)'},
    {tostring(undump(bit.bor)), '(?)'}
}

for _, case in ipairs(cases) do
    local actual, expected = case[1], case[2]
    assert(actual == expected, ('Expected %q, but got %q instead.'):format(expected, actual))
end

print("Success!\n")