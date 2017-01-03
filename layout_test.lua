local layout = require 'see.layout'
local undump = require 'see.undump'

local keys = {}
for k, v in pairs(string) do
    if v then
        table.insert(keys, k .. tostring(undump(v)))
    end
end
local meh = layout.layout(keys)
print(('%s%s'):format(meh, #meh - 1))