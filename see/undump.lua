local reader = require 'see.reader'

local function undump(str_or_function)
    local str = str_or_function
    if type(str_or_function) == 'function' then
        str = string.dump(str_or_function)
    end
    assert(type(str) == 'string', "You can only undump functions or bytecode")
    local ctx = reader.new_reader(str)
    local undump
    if ctx:int() == 0x61754c1b then -- ESC. Lua - vanilla lua
        local version = ctx:byte()
        if version == 0x51 then
            undump = require 'see.undump51'
        elseif version == 0x52 then
            undump = require 'see.undump52'
        elseif version == 0x53 then
            undump = require 'see.undump53'
        else
            error "Only Lua 5.{1,2,3} and LuaJIT2 are supported."
        end
    elseif ctx:rewind():int(3) == 0x4a4c1b then -- ESC. JK - luajit
        undump = require 'see.undumpjit2'
    else
        error "Only Lua 5.{1,2,3} and LuaJIT2 are supported."
    end
    return undump.undump(str)
end

return undump