#!/bin/bash

echo "Testing Lua 5.1"
lua5.1 undump_test.lua

echo "Testing Lua 5.2"
lua5.2 undump_test.lua

echo "Testing Lua 5.3"
lua5.3 undump_test.lua

echo "Testing LuaJit"
luajit undump_test.lua
