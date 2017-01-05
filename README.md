# See.lua 

*An introspection library for Lua 5.1, 5.2, 5.3, and LuaJIT*

```lua
> see(_G)
._G[37]             ._VERSION = "Lua 5.3"                   .arg[1]
.assert(?)          .bit32[12]          .collectgarbage(?)  .coroutine[7]
.debug[16]          .dofile(?)          .error(?)           .getmetatable(?)
.io[14]             .ipairs(?)          .load(?)            .loadfile(?)
.math[35]           .next(?)            .os[11]             .package[8]
.pairs(?)           .pcall(?)           .print(?)           .rawequal(?)
.rawget(?)          .rawlen(?)          .rawset(?)          .require(?)
.see(object, query) .select(?)          .setmetatable(?)    .string[17]
.table[7]           .tonumber(?)        .tostring(?)        .type(?)
.utf8[6]            .xpcall(?)
```

------------------------------------------------------------------------
### Demo

<p align=center>
<a href='https://asciinema.org/a/6ny1px38azbo3sk76c71oi8th' align=center>
<img width=500 src='https://asciinema.org/a/6ny1px38azbo3sk76c71oi8th.png'/>
</a>
</p>

------------------------------------------------------------------------

### Installation

`see.lua` depends on either Lua 5.1 and above or LuaJIT. In addition, since `see.lua` disassembles
user functions automatically, it depends on the `bit32` library for byte-stream manipulation.

```bash
$ luarocks install see
```

### Usage

```lua
local see = require 'see'
see(_G, 'print|error')
```

------------------------------------------------------------------------

### Documentation

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
.convert(token)     .default_action(...)                    .epilogue(...)
.grammar[84]        .ll1[83]            .prologue(stream)

Metatable:
.__call(this, str)
```

Oooh, now that's fancy. Notice how tables are listed with their size and functions with their parameters. 
Even functions with variadic parameters `(...)` are listed correctly. Notice too that the metatables 
are listed as well. In this case, the `parser` library contains a single `__call` element that takes in a string,
presumably the string to be parsed.

Now, does this work with lists as well?

```lua
> list = {} for i = 1, 200 do table.insert(list, i) end
> see(list)
{1,  2,  3,  4,  5,  6,  7,  8,  9,  10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60,
 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80,
 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99,
 100,    101,    102,    103,    104,    105,    106,    107,    108,    109,
 110,    111,    112,    113,    114,    115,    116,    117,    118,    119,
 120,    121,    122,    123,    124,    125,    126,    127,    128,    129,
 130,    131,    132,    133,    134,    135,    136,    137,    138,    139,
 140,    141,    142,    143,    144,    145,    146,    147,    148,    149,
 150,    151,    152,    153,    154,    155,    156,    157,    158,    159,
 160,    161,    162,    163,    164,    165,    166,    167,    168,    169,
 170,    171,    172,    173,    174,    175,    176,    177,    178,    179,
 180,    181,    182,    183,    184,    185,    186,    187,    188,    189,
 190,    191,    192,    193,    194,    195,    196,    197,    198,    199,
 200}
```

Wow, it even lines up all of the columns for you!

Let's go back to the `parser` example. Notice how there are `84` elements in the `parser.grammar` table. We can
actually "see" them as well via

```lua
> see(parser).grammar
{"luainlua/lua/parser_table.lua"}

.args'maybe#1[3]    .args[4]            .assignment'star#1[3]
.assignment[3]      .assignment_or_call'group#1[5]          .binop[16]
.assignment_or_call'maybe#1[3]          .assignment_or_call'star#1[4]
.assignment_or_call[2]                  .block'maybe#1[3]   .block'star#1[3]
.block[2]           .exp'[3]            .exp2'[3]           .exp2[2]
.exp3'[3]           .exp3[2]            .exp4'group#1[2]    .exp4'maybe#1[3]
.exp4[2]            .exp5'[4]           .exp5[2]            .exp6'[3]
.exp6[2]            .exp7[3]            .exp8'group#1[2]    .exp8'maybe#1[3]
.exp8[2]            .exp[2]             .exp_stop'star#1[4] .exp_stop[10]
.explist'group#1[2] .explist'star#1[3]  .explist[2]         .field'maybe#1[3]
.field'maybe#2[3]   .field'maybe#3[3]   .field[5]           .fieldsep[3]
.funcbody'maybe#1[3]                    .funcbody[2]        .funcname'star#1[3]
.funcname'group#1[2]                    .funcname'group#2[2]
.funcname'maybe#1[3]                    .funcname[2]        .functiondef[2]
.label[2]           .level1[2]          .level2[2]          .level3[7]
.level4[2]          .level5[3]          .level6[4]          .level7[4]
.level8[2]          .namelist'group#1[2]                    .namelist'star#1[3]
.namelist[2]        .parlist'group#1[2] .parlist'group#2[3] .parlist'star#1[4]
.parlist[2]         .primaryexp[3]      .retstat'maybe#1[3] .retstat'maybe#2[3]
.retstat[2]         .root[2]            .stat'group#1'group#1[2]
.stat'group#1'maybe#1[3]                .stat'group#1[3]    .stat'group#2[4]
.stat'group#2'group#1[2]                .stat'group#2'maybe#1[3]
.stat'group#3[2]    .stat'group#4[2]    .stat'maybe#1[3]    .stat'star#1[3]
.stat[13]           .suffix[5]          .tableconstructor'star#1[3]
.tableconstructor[2]                    .unop[4]

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
.convert(token)     .default_action(...)                    .epilogue(...)
.grammar[84]        .ll1[83]            .prologue(stream)

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

> see(math, "tan").atan("?")
function(<?>) {native}
```

<p><img src='http://i.imgur.com/rGHHLFy.png' align=center/></p>

On Ansi-compatible terminals, you would see actual highlighting, whereas they are replaced by
tags `<>` on windows.