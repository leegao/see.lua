# See.lua 

*A Lua introspection library for Lua 5.1, 5.2, 5.3, and LuaJIT*

```lua
> see(_G)
.string[14]         .debug[16]          .rawlen(?)          .pairs(?)
.loadfile(?)        ._VERSION = "Lua 5.2"                   .rawget(?)
.next(?)            .math[30]           .print(?)           .type(?)
.loadstring(?)      .assert(?)          .os[11]             .require(?)
.select(?)          .module(?)          .rawset(?)          .tonumber(?)
.coroutine[6]       .collectgarbage(?)  .xpcall(?)          .dofile(?)
.rawequal(?)        .load(?)            .ipairs(?)          .getmetatable(?)
.table[7]           .see(object, query) .bit32[12]          .io[14]
.unpack(?)          .pcall(?)           .package[10]        .error(?)
.tostring(?)        .setmetatable(?)    ._G[38]
```

------------------------------------------------------------------------
#### Demo

[![asciicast](https://asciinema.org/a/6ny1px38azbo3sk76c71oi8th.png)](https://asciinema.org/a/6ny1px38azbo3sk76c71oi8th)

------------------------------------------------------------------------

#### Installation

```bash
$ luarocks install see.lua
```

#### Usage

```lua
local see = require 'see'
see(_G, 'print|error')
```

#### Documentation

Lua is a wonderful little language that lets you do a lot of cool stuff. However it's not very friendly to curious
people. For example, let's say that we were just given a random library:

```lua
> local parser = require 'luainlua.lua.parser'
```

and we want to see what's offered:

```lua
> parser
table: 0x913e00
```

Wait wait wait, what is it with all these numbers? All I wanted to do is to know what's inside the `parser` table. 
Now there's an easy solution for these types of situations:

```lua
> see(parser)
.grammar[84]        .ll1[83]            .prologue(stream)   .epilogue(...)
.default_action(...)                    .convert(token)

Metatable:
.__call(this, str)
```

Oooh, now that's fancy. Notice how tables are listed with their size and functions with their parameters. 
Even functions with variadic parameters `(...)` are listed correctly. Notice too that the metatables 
are listed as well. In this case, the `parser` library contains a single `__call` element that takes in a string,
presumably the string to be parsed.

Now, does this work with lists as well?

```lua
> see {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25}
  {1,  2,  3,  4,  5,  6,  7,  8,  9,  10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
   21, 22, 23, 24, 25}
```

Wow, it even lines up all of the columns for you!

Let's go back to the `parser` example. Notice how there are `84` elements in the `parser.grammar` table. We can
actually "see" them as well via

```lua
> see(parser).grammar
{"luainlua/lua/parser_table.lua"}

.funcname'maybe#1[3]                    .functiondef[2]     .unop[4]
.retstat'maybe#2[3] .block'star#1[3]    .level7[4]          .block[2]
.exp7[3]            .assignment'star#1[3]                   .funcbody[2]
.root[2]            .assignment_or_call'maybe#1[3]          .field'maybe#3[3]
...
> see(parser).grammar.root
{table[2]}

.variable = "$root"
> see(parser).grammar.root[1]
{"$block"}

.action(_1)
```

So we know that `parser.grammar.root[1] = {"$block", action = function(_1) ... end}`.

Now, imagine that I'm debugging these grammars. I would like to know a little bit more about the
`.action(_1)` function. By selecting it, you can view its metadata.

```lua
> see(parser).grammar.root[1].action
function(_1) {@/home/leegao/distro/install/share/lua/5.1/luainlua/lua/parser.lua 421:423}
```

In fact, if the source-code is present, you can even view it directly

```lua
> see(parser).grammar.root[1].action.sourcecode

__GRAMMAR__.grammar["root"][1].action = function(_1)
  return  _1
end
```

Neato.

What's more, you can also select the metatable using the `.mt` field, like so

```lua
> see(parser)
.grammar[84]        .ll1[83]            .prologue(stream)   .epilogue(...)
.default_action(...)                    .convert(token)

Metatable:
.__call(this, str)

> see(parser).mt
.__call(this, str)

> see(parser).mt.__call.sourcecode
{__call = function(this, str)
  local tokens = {}
  for _, token in ipairs(this.prologue(str)) do
    table.insert(
      tokens,
      setmetatable(
        token,
        {__tostring = function(self) return this.convert(self) end}))
  end
  local result = this.ll1:parse(tokens)
  return this.epilogue(result)
end})
```

We can also supply an optional query into `see` to highlight our results. 
For example, suppose that we want to only see functions related to tan in the mathematics library:

```lua
> see(math, "tan")
.log(?)         .max(?)         .acos(?)        .huge = 1.#INF  .ldexp(?)
.pi = 3.1415926535898           .cos(?)         .<tan>h(?)      .pow(?)
.deg(?)         .<tan>(?)       .cosh(?)        .sinh(?)        .random(?)
.randomseed(?)  .frexp(?)       .ceil(?)        .floor(?)       .rad(?)
.abs(?)         .sqrt(?)        .modf(?)        .asin(?)        .min(?)
.mod(?)         .fmod(?)        .log10(?)       .a<tan>2(?)     .exp(?)
.sin(?)         .a<tan>(?)

> see(math, "tan").atan("atan")
function(<?>) {native}
```

<p><img src='http://i.imgur.com/rGHHLFy.png' align=center/></p>

On Ansi-compatible terminals, you would see actual highlighting, whereas they are replaced by
tags `<>` on windows.