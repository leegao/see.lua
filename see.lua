local undump = require 'see.undump'
local layout = require 'see.layout'
local utils  = require 'see.utils'

local function format(object, name)
    if name == nil then
        if type(object) == 'function' then
            return ('%s%s'):format('function', undump(object))
        elseif type(object) == 'table' then
            local size = 0
            for _ in pairs(object) do size = size + 1 end
            return ('%s[%s]'):format('table', size)
        elseif type(object) == 'string' then
            return ('"%s"'):format(object)
        else
            return tostring(object)
        end
    end

    if type(name) == 'string' then
        if type(object) == 'function' then
            return ('.%s%s'):format(name, undump(object))
        elseif type(object) == 'table' then
            local size = 0
            for _ in pairs(object) do size = size + 1 end
            return ('.%s[%s]'):format(name, size)
        elseif type(object) == 'string' then
            return ('.%s = "%s"'):format(name, object)
        else
            return name and ('%s = %s'):format(name, object)
        end
    end

    return ('[%s] = %s'):format(format(name), format(object))
end

local function pprint_list(enumerable)
    local list = utils.map(format, enumerable)
    return ('{%s}'):format(layout.layout(list, 20, 1, 60, ',', ' ', true))
end

function see(object)
    if type(object) == 'function' then
        return ('function%s'):format(undump(object))
    elseif type(object) == 'table' then
        -- get its ipairs, key-val, and metatable
        local enumerable = {}
        for _, v in ipairs(object) do table.insert(enumerable, v) end
        local output = ''
        if #enumerable > 0 then
            output = pprint_list(enumerable) .. '\n\n'
        end
        local kv = {}
        for k, v in pairs(object) do table.insert(kv, format(v, k)) end
        output = output .. layout.layout(kv, 5, 0.9)
        if getmetatable(object) then
            local mt = {}
            for k, v in pairs(getmetatable(object)) do table.insert(mt, format(v, k)) end
            output = output .. "\n\nMetatable:\n" .. layout.layout(mt, 5, 0.9)
        end
        return setmetatable(
            {},
            {
                __tostring = function() return output end,
                __index = function(self, k)
                    if k == 'mt' then return see(getmetatable(object)) end
                    return see(object[k])
                end,
                __call = function(self, ...) return see(object, ...) end
            }
        )
    else
        return tostring(object)
    end
end

return see