local function ReadInt(str)
	local t = {}
	for w in str:gmatch(".") do table.insert(t, w:byte()) end
	return t[1]+t[2]*256+t[3]*256^2+t[4]*256^3
end

local function num_args(func)
	local ok = pcall(function() string.dump(func) end)
	if not ok then return "?" end
	local dump = string.dump(func)
	--Set up the cursor
	local cursor = 13
	local offset = ReadInt(dump:sub(cursor, cursor + 4))
	cursor = cursor + 13 + offset
	--Get the Parameters
	local numParams = dump:sub(cursor, cursor + 1):byte()
	cursor = cursor + 1
	--Get the Variable-Args flag (whether there's a ... in the param)
	local varFlag = dump:sub(cursor, cursor + 1):byte()

	local ret = tostring(numParams)
	if varFlag > 1 then ret = ret .. "+" end

	return ret
end

function get_args(func)
	local function _get_args(dump, cursor)
		if not cursor then cursor = 13 end
		local offset = ReadInt(dump:sub(cursor, cursor + 4))
		cursor = cursor + offset + 13
		local numParams = dump:sub(cursor, cursor + 1):byte()
		cursor = cursor + 1
		local varFlag = dump:sub(cursor, cursor + 1):byte()
		cursor = cursor + 2
		local offset = ReadInt(dump:sub(cursor, cursor + 4))
		cursor = cursor + (offset+1)*4
		local offset = ReadInt(dump:sub(cursor, cursor + 4))
		cursor = cursor + 4
		for i=1,offset do
			local tp = dump:sub(cursor, cursor):byte()
			cursor = cursor + 1
			if tp == 1 then
				cursor = cursor + 1
			elseif tp == 3 then
				cursor = cursor + 8
			elseif tp == 4 then
				local off = ReadInt(dump:sub(cursor, cursor + 4))
				cursor = cursor + off + 4
			end
		end
		local offset = ReadInt(dump:sub(cursor, cursor + 4))
		cursor = cursor + 4
		for i=1, offset do
			local _
			_, cursor = _get_args(dump, cursor)
		end
		local offset = ReadInt(dump:sub(cursor, cursor + 4))
		cursor = cursor + (offset+1)*4
		local offset = ReadInt(dump:sub(cursor, cursor + 4))
		cursor = cursor + 4
		local params = {}
		for i=1,offset do
			local off = ReadInt(dump:sub(cursor, cursor + 4))
			cursor = cursor + 4
			local varname = dump:sub(cursor, cursor+off)
			if i <= numParams then table.insert(params,varname) end
			cursor = cursor + off + 8
		end
		if varFlag > 1 then table.insert(params, "...") end
		local offset = ReadInt(dump:sub(cursor, cursor + 4))
		cursor = cursor + 4
		for i=1,offset do
			local off = ReadInt(dump:sub(cursor, cursor + 4))
			cursor = cursor + off + 4
		end
		return params, cursor
	end
	if not pcall(function() string.dump(func) end) then return {"?"} end
	local args = {_get_args(string.dump(func))}
	return args[1]
end

function string.join(self, table, ...)
	local str = string.format(("%s"..self):rep(#table), unpack(table))
	return str:sub(1, #str-#self)
end

-- See
function see(object, query)
	--[[--
	Introspection library for Lua
	--]]--
	if not query then query = "*" end
	local function _keys(Table)
		local tab = {}
		for k in pairs(Table) do
			if type(k) == "string" then
				table.insert(tab, k)
			end
		end
		return tab
	end
	local function _len(Table)
		local n = 0
		for i in pairs(Table) do
			n = n + 1
		end
		return n
	end
	local function _just(str, limit)
		if not limit then limit = 20 end

		if #str <= limit then
			return str .. string.rep(" ", limit-#str)
		else
			return str .. string.rep(" ", math.ceil(#str/limit)*limit-#str)
		end
	end
	local function _introspect(Table, prefix, postfix, translate)
		local keys = _keys(Table)
		table.sort(keys)
		if not translate then translate = {} end
		local str = ""
		local n = 1
		for _,k in ipairs(keys) do
			--Setup Query Condition:
			if query and type(k) ~= "number" then
				if type(query) ~= "string" or limit == "*" then
					--Pass
				else
					--Cases:
					-- name -> abs match
					-- name* -> relative match
					-- *name -> relative match
					if ("$"..k):find(query:gsub("\*", ".*")) then
						local pre = ""
						local post = ""

						local Type = type(Table[k])
						if (Type == "table") then
							post = string.format("[%s]", _len(Table[k]))
						elseif (Type == "function") then
							local del = ", "
							post = string.format("(%s)",del:join(get_args(Table[k])))
						end

						if prefix then pre = prefix end
						if postfix then post = postfix end

						if translate[k] then k = translate[k] end
						local format = string.format("%s%s%s",pre,k,post)
						if #format > 20 then n = n +  math.ceil(#str/20)-1 end
						if (n==0 or n%4>0) then
							str = str .. _just(format, 20)
						else
							str = str .. format .. "\n"
						end

						n = n + 1
					end
				end
			end
		end
		if #str > 0 then
			print(str)
		end
	end
	if not level then level = 0 end
	if type(object) == "table" then
		--print "+ Table Elements"
		_introspect(object, ".")
		local d = dump(object)
		if #d > 2 then print(d) end
	elseif type(object) == "function" then
		print(string.format("function(%s)",string.join(", ",get_args(object))))
	else
		print("@"..string.upper(type(object)),object)
	end
	local _mt = getmetatable(object)
	local _mt_translate = {
		__index = ".",
		__call = "()",
		__add = "+",
		__sub = "-",
		__mul = "*",
		__div = "/",
		__mod = "%",
		__pow = "^",
		__unm = "-.",
		__concat = "..",
		__len = "#",
		__eq = "==",
		__lt = "<",
		__le = "<=",
		__newindex = ":=",
		__gc = "GC",
		__tostring = "tostring()",
		__tonumber = "tonumber()",
	}
	if _mt then
		print "Metatable"
		_introspect(_mt, "", "", _mt_translate)
	end

	local _return = newproxy(true)
	local __mt = getmetatable(_return)
	__mt.__index = function(self, key)
		if type(object) ~= "table" then return end
		if object[key] then
			print("\n@"..tostring(key))
			return see(object[key])
		end
	end
	__mt.__call = function(self)
		return self
	end
	return _return
end

function dump(list)
	local str = "{"
	local seen = {}
	for _,v in ipairs(list) do
		if type(v) ~= "table" then
			str = str .. tostring(v) .. ", "
		else
			str = str .. dump(v) .. ", "
		end
		seen[_] = true
	end
	if #list > 0 then
		str = str:sub(1, #str-2)
	end
	local trim = false
--~ 	for k,v in pairs(list) do
--~ 		if not seen[k] then
--~ 			trim = true
--~ 			if type(v) ~= "table" then
--~ 				str = str .. tostring(k) .. " = " .. tostring(v) .. ", "
--~ 			else
--~ 				str = str .. tostring(k) .. " = " .. dump(v) .. ", "
--~ 			end
--~ 		end
--~ 	end
	if trim then str = str:sub(1, #str-2) end
	str = str .. "}"
	return str
end

-- Git test
