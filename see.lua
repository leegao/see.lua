local undump = require 'see.undump'
local layout = require 'see.layout'
local utils  = require 'see.utils'

local function to_control_sequence(char)
    return string.format("\\%03d", string.byte(char))
end

local function escape(str)
    -- replace non-ascii characters in str with their \xxx control code
    local output = str:gsub("%c", to_control_sequence)
    return output
end

local function format(object, name)
    if name == nil then
        if type(object) == 'function' then
            return ('function%s'):format(tostring(undump(object)))
        elseif type(object) == 'table' then
            local size = 0
            for _ in pairs(object) do size = size + 1 end
            return ('table[%s]'):format(tostring(size))
        elseif type(object) == 'string' then
            return escape(('%q'):format(object))
        else
            return tostring(object)
        end
    end

    -- If we have a name and it doesn't need to be quoted, use the .name format
    if type(name) == 'string' and escape(('%q'):format(name)) == ('"%s"'):format(name) then
        if type(object) == 'function' then
            return ('.%s%s'):format(name, tostring(undump(object)))
        elseif type(object) == 'table' then
            local size = 0
            for _ in pairs(object) do size = size + 1 end
            return ('.%s[%s]'):format(name, tostring(size))
        elseif type(object) == 'string' then
            return escape(('.%s = %q'):format(name, object))
        else
            return name and ('.%s = %s'):format(name, tostring(object))
        end
    end

    return ('[%s] = %s'):format(format(name), format(object))
end

local function pprint_list(enumerable)
    local list = utils.map(format, enumerable)
    return ('{%s}'):format(layout.layout(list, 20, 1, 60, ',', ' ', true))
end

local function lines(str)
    local t = {}
    local function helper(line) table.insert(t, line) return "" end
    helper((str:gsub("(.-)\r?\n", helper)))
    return t
end

local function see(object, query)
    local output = ''
    if type(object) == 'function' then
        local proto = undump(object)
        local line = ''
        if proto.source then
            line = (' %s:%s'):format(tostring(proto.first_line), tostring(proto.last_line))
        end

        output = ('function%s {%s%s}'):format(tostring(proto), proto.source or 'native', line)
    elseif type(object) == 'table' then
        -- get its ipairs, key-val, and metatable
        local enumerable = {}
        for _, v in ipairs(object) do table.insert(enumerable, v) end
        if #enumerable > 0 then
            output = pprint_list(enumerable) .. '\n\n'
        end
        local kv = {}
        for k, v in pairs(object) do
            if not enumerable[k] then
                table.insert(kv, format(v, k))
            end
        end
        table.sort(kv)
        output = output .. layout.layout(kv, 4, 0.9)
        if getmetatable(object) then
            local mt = {}
            for k, v in pairs(getmetatable(object)) do table.insert(mt, format(v, k)) end
            table.sort(mt)
            output = output .. "\n\nMetatable:\n" .. layout.layout(mt, 4, 0.9)
        end
    else
        output = tostring(object)
    end
    if query then
        local i, j = output:find(query)
        local highlighting = {}
        while i and j do
            table.insert(highlighting, {i, j})
            i, j = output:find(query, j + 1)
        end
        local highlight = require 'see.highlight'
        output = highlight(output, highlighting)
    end
    return setmetatable(
        {},
        {
            __tostring = function() return output end,
            __index = function(self, k)
                if k == 'sourcecode' and type(object) == 'function' then
                    local proto = undump(object)
                    if proto.source and proto.source:sub(1, 1) == '@' then
                        local source = proto.source:sub(2)
                        local f = io.open(source, 'r')
                        if f then
                            local code = f:read('*all')
                            f:close()
                            local code_lines = lines(code)
                            return table.concat(utils.sublist(code_lines, proto.first_line, proto.last_line), '\n')
                        end
                    end
                end
                if k == 'mt' then return see(getmetatable(object)) end
                return see(object[k])
            end,
            __call = function(self, ...) return see(object, ...) end
        }
    )
end

return see