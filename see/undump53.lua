-- Load the function prototype on lua52
local reader = require 'see.reader'
local utils = require 'see.utils'
local undump53 = {}

--func52.sizeof_int = 4
--func52.sizeof_sizet = 4
--func52.sizeof_instruction = 4
undump53.sizeof_integer = 8
undump53.sizeof_number = 8

local function generic_list(ctx, parser, size)
    local n = ctx:int(size)
    local ret = {}
    for i = 1, n do
        table.insert(ret, parser(ctx))
    end
    return ret
end

local function load_string(ctx)
    local size = ctx:byte()
    if size == 0xff then
        size = ctx:int()
    end
    if size == 0 then return end
    local str = ctx[1]:sub(ctx[2], ctx[2]+size-2)
    ctx[2] = ctx[2] + size - 1
    return str
end

local function constant(ctx)
    local type = ctx:byte()

    if type == 0 then
        return {} -- nil
    elseif type == 1 then -- boolean
        return ctx:byte() ~= 0
    elseif type == 3 then
        return ctx:double()
    elseif type == 19 then
        return ctx:int(undump53.sizeof_integer)
    elseif type == 4 or type == 20 then
        return load_string(ctx)
    else
        error(("Cannot parse constant for type %s."):format(type))
    end
end

function undump53.load_header(ctx)
    assert(ctx:int() == 0x61754c1b, "Make sure you're running vanilla Lua 5.3") -- ESC. Lua
    assert(ctx:byte() == 0x53, "Make sure you're running vanilla Lua 5.3") -- version
    assert(ctx:byte() == 0, "Not expecting extensions.") -- format version
    -- "\x19\x93\r\n\x1a\n"
    assert(ctx:int() == 0xa0d9319, "corrupted")
    assert(ctx:short() == 0x0a1a, "corrupted")
--    assert(ctx:byte() == 1, "Not expecting big-endianess.") -- little endian
    if not undump53.sizeof_int then
        assert(ctx:byte() == 4)
        undump53.sizeof_int = 4 -- sizeof(int)
        undump53.sizeof_sizet = assert(ctx:byte()) -- sizeof(size_t)
        undump53.sizeof_instruction = assert(ctx:byte()) -- sizeof(Instruction)
    else
        assert(ctx:byte() == undump53.sizeof_int) -- sizeof(int)
        assert(ctx:byte() == undump53.sizeof_sizet) -- sizeof(size_t)
        assert(ctx:byte() == undump53.sizeof_instruction) -- sizeof(Instruction)
    end
    assert(ctx:byte() == undump53.sizeof_integer) -- sizeof(number)
    assert(ctx:byte() == undump53.sizeof_number) -- sizeof(number)
    assert(ctx:int(8) == 0x5678, "wrong endianness")
    assert(ctx:double() == 370.5, "wrong endianness")
end

function undump53.load_code(ctx)
    local n = ctx:int()
    local instructions = {}
    for i = 1, n do
        local int = ctx:int(undump53.sizeof_instruction)
        table.insert(instructions, int)
    end
    return instructions
end

function undump53.load_constants(ctx)
    local constants = generic_list(ctx, constant)
    local upvalues = undump53.load_upvalues(ctx)
    constants.functions = generic_list(ctx, undump53.load_function)
    return constants, upvalues
end

function undump53.load_upvalues(ctx)
    return generic_list(
        ctx,
        function(ctx)
            return {instack = ctx:byte(), index = ctx:byte()}
        end
    )
end

function undump53.load_debug(ctx)
    local lineinfo = generic_list(ctx, function(ctx) return ctx:int() end)
    local locals = generic_list(
        ctx,
        function(ctx)
            return {name = load_string(ctx), first_pc = ctx:int(), last_pc = ctx:int()}
        end
    )
    local upvalues = generic_list(ctx, load_string)
    return {
        lineinfo = lineinfo,
        locals = locals,
        upvalues = upvalues,
    }
end

function undump53.load_function(ctx)
    local source       = load_string(ctx)
    local first_line   = ctx:int()
    local last_line    = ctx:int()
    local nparams      = ctx:byte()
    local is_vararg    = ctx:byte()
    local stack_size   = ctx:byte()
    local code         = undump53.load_code(ctx)
    local constants, up= undump53.load_constants(ctx)
    local debug        = undump53.load_debug(ctx)

    debug.source = source

    return {
        first_line   = first_line,
        last_line    = last_line,
        nparams      = nparams,
        is_vararg    = is_vararg,
        stack_size   = stack_size,
        code         = code,
        constants    = constants,
        upvalues     = up,
        debug        = debug,
    }
end

function undump53.undump(str_or_function)
    local str = str_or_function
    if type(str_or_function) == 'function' then
        str = string.dump(str_or_function)
    end
    assert(type(str) == 'string', "You can only undump functions or bytecode")
    local ctx = reader.new_reader(str)
    undump53.load_header(ctx) -- verify
    local nupvalues = ctx:byte()
    local func = undump53.load_function(ctx)
    assert(ctx[2] > #ctx[1], "There is some extra data left inside the bytecode.")
    return setmetatable(
        func,
        {
            __tostring = function(self)
                local nparams = self.nparams
                local params = utils.sublist(self.debug.locals, 1, nparams)
                if #params ~= nparams then return ('(%s arguments)'):format(nparams) end
                return ('(%s)'):format(table.concat(utils.map(function(x) return x.name end, params), ', '))
            end
        })
end

return undump53