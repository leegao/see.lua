package = "see"
version = "0.1-1"
source = {
   url = "git://github.com/leegao/see.lua",
   tag = "v0.1-1",
   dir = "see.lua",
}
description = {
   summary = "An introspection library for Lua",
   detailed = [[
      An introspection library that reports human-friendly summaries of Lua tables.
   ]],
   homepage = "https://github.com/leegao/see.lua",
   license = "MIT",
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
