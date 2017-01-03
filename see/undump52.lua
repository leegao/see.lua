-- Load the function prototype on lua52
local reader = require 'see.reader'
local utils = require 'see.utils'
local undump52 = {}

--func52.sizeof_int = 4
--func52.sizeof_sizet = 4
--func52.sizeof_instruction = 4
undump52.sizeof_number = 8

local function generic_list(ctx, parser, size)
    local n = ctx:int(size)
    local ret = {}
    for i = 1, n do
        table.insert(ret, parser(ctx))
    end
    return ret
end

local function constant(ctx)
    local type = ctx:byte()

    if type == 0 then
        return {} -- nil
    elseif type == 1 then -- boolean
        return ctx:byte() ~= 0
    elseif type == 3 then
        return ctx:double()
    elseif type == 4 then
        return ctx:string(undump52.sizeof_sizet)
    else
        error "Cannot parse constant"
    end
end

function undump52.load_header(ctx)
    assert(ctx:int() == 0x61754c1b, "Make sure you're running vanilla Lua 5.2") -- ESC. Lua
    assert(ctx:byte() == 0x52, "Make sure you're running vanilla Lua 5.2") -- version
    assert(ctx:byte() == 0, "Not expecting extensions.") -- format version
    assert(ctx:byte() == 1, "Not expecting big-endianess.") -- little endian
    if not undump52.sizeof_int then
        assert(ctx:byte() == 4)
        undump52.sizeof_int = 4 -- sizeof(int)
        undump52.sizeof_sizet = assert(ctx:byte()) -- sizeof(size_t)
        undump52.sizeof_instruction = assert(ctx:byte()) -- sizeof(Instruction)
    else
        assert(ctx:byte() == undump52.sizeof_int) -- sizeof(int)
        assert(ctx:byte() == undump52.sizeof_sizet) -- sizeof(size_t)
        assert(ctx:byte() == undump52.sizeof_instruction) -- sizeof(Instruction)
    end
    assert(ctx:byte() == undump52.sizeof_number) -- sizeof(number)
    assert(ctx:byte() == 0) -- is integer
    assert(ctx:int() == 0x0a0d9319) -- TAIL
    assert(ctx:short() == 0x0a1a) -- MORE TAIL
    return
end

function undump52.load_code(ctx)
    local ir = ctx:get_ir()
    local n = ctx:int()
    local instructions = {}
    for i = 1, n do
        local int = ctx:int(undump52.sizeof_instruction)
        table.insert(instructions, int)
    end
    return instructions
end

function undump52.load_constants(ctx)
    local constants = generic_list(ctx, constant)
    constants.functions = generic_list(ctx, undump52.load_function)
    return constants
end

function undump52.load_upvalues(ctx)
    return generic_list(
        ctx,
        function(ctx)
            return {instack = ctx:byte(), index = ctx:byte()}
        end
    )
end

function undump52.load_debug(ctx)
    local source = ctx:string(undump52.sizeof_sizet)
    local lineinfo = generic_list(ctx, function(ctx) return ctx:int() end)
    local locals = generic_list(
        ctx,
        function(ctx)
            return {name = ctx:string(undump52.sizeof_sizet), first_pc = ctx:int(), last_pc = ctx:int()}
        end
    )
    local upvalues = generic_list(ctx, function(ctx) return ctx:string(undump52.sizeof_sizet) end)
    return {
        source = source,
        lineinfo = lineinfo,
        locals = locals,
        upvalues = upvalues,
    }
end

function undump52.load_function(ctx)
    local first_line   = ctx:int()
    local last_line    = ctx:int()
    local nparams      = ctx:byte()
    local is_vararg    = ctx:byte()
    local stack_size   = ctx:byte()
    local code         = undump52.load_code(ctx)
    local constants    = undump52.load_constants(ctx)
    local upvalues     = undump52.load_upvalues(ctx)
    local debug        = undump52.load_debug(ctx)

    return {
        first_line   = first_line,
        last_line    = last_line,
        nparams      = nparams,
        is_vararg    = is_vararg,
        stack_size   = stack_size,
        code         = code,
        constants    = constants,
        upvalues     = upvalues,
        debug        = debug,
    }
end

function undump52.undump(str_or_function)
    local str = str_or_function
    if type(str_or_function) == 'function' then
        str = string.dump(str_or_function)
    end
    assert(type(str) == 'string', "You can only undump functions or bytecode")
    local ctx = reader.new_reader(str)
    ctx.ir_stack = {}
    function ctx:get_ir()
        return self.ir_stack[#self.ir_stack]
    end
    undump52.load_header(ctx) -- verify
    local func = undump52.load_function(ctx)
    assert(ctx[2] > #ctx[1], "There is some extra data left inside the bytecode.")
    return setmetatable(
        func,
        {
            __tostring = function(self)
                local nparams = self.nparams
                local is_vararg = self.is_vararg ~= 0
                local params = utils.map(
                    function(x) return x.name end,
                    utils.sublist(self.debug.locals, 1, nparams))
                if #params ~= nparams then
                    return ('(%s arguments%s)'):format(nparams, is_vararg and ' and varargs' or '')
                end
                if is_vararg then table.insert(params, '...') end
                return ('(%s)'):format(table.concat(params, ', '))
            end
        })
end

return undump52