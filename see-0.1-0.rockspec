package = "see"
version = "0.1-0"
source = {
   url = "git://github.com/leegao/see.lua",
}
description = {
   summary = "An introspection library for Lua",
   detailed = [[
      This is an example for the LuaRocks tutorial.
      Here we would put a detailed, typically
      paragraph-long description.
   ]],
   homepage = "git://github.com/leegao/see.lua", -- We don't have one yet
   license = "MIT/X11" -- or whatever you like
}
dependencies = {
   "lua >= 5.1",
   "bit32",
}
build = {
   type = "builtin",
   modules = {
     ['see'] = 'see.lua/see.lua',
     ['see.highlight'] = 'see.lua/see/highlight.lua',
     ['see.layout'] = 'see.lua/see/layout.lua',
     ['see.reader'] = 'see.lua/see/reader.lua',
     ['see.undump'] = 'see.lua/see/undump.lua',
     ['see.undump51'] = 'see.lua/see/undump51.lua',
     ['see.undump52'] = 'see.lua/see/undump52.lua',
     ['see.undump53'] = 'see.lua/see/undump53.lua',
     ['see.undumpjit2'] = 'see.lua/see/undumpjit2.lua',
     ['see.utils'] = 'see.lua/see/utils.lua',
   },
}
