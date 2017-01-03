local reader = require 'see.reader'

local function undump(str_or_function)
    local str = str_or_function
    if type(str_or_function) == 'function' then
        str = string.dump(str_or_function)
    end
    assert(type(str) == 'string', "You can only undump functions or bytecode")
    local ctx = reader.new_reader(str)
    assert(ctx:int() == 0x61754c1b, "Make sure you're running vanilla Lua") -- ESC. Lua
    local version = ctx:byte()
    local undump = nil
    if version == 0x51 then
        undump = require 'see.undump51'
    elseif version == 0x52 then
        undump = require 'see.undump52'
    elseif version == 0x53 then
        undump = require 'see.undump53'
    else
        error "Only Lua 5.{1,2,3} are supported."
    end
    return undump.undump(str)
end

return undump