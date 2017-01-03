local undump = require 'see.undump52'
local reader = require 'see.reader'

local fun = undump.undump(function(a, b, c) end)
print(fun)