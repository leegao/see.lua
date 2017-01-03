local undump = require 'see.undump'
local bit = require 'bit32'

assert(tostring(undump(undump)) == '(str_or_function)')
assert(tostring(undump(function() end)) == '()')
assert(tostring(undump(function(a, b, c) end)) == '(a, b, c)')
assert(tostring(undump(function(a, b, ...) end)) == '(a, b, ...)')
assert(tostring(undump(bit.bor)) == '(?)')

print("Success!\n")