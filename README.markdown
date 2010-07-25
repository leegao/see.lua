See.lua - A Lua introspection library

	> see(string)

	.byte(?)            .char(?)            .dump(?)            .find(?)
	.format(?)          .gfind(?)           .gmatch(?)          .gsub(?)
	.join(self, table, ...)                 .len(?)
	.lower(?)           .match(?)           .rep(?)             .reverse(?)
	.sub(?)             .upper(?)

Lua is a wonderful little language that lets you do a lot of cool stuff. However it's not very friendly to those of you who are more curious. For example, let's say that we were just given a random library:

	> require "lanes"

and we want to see what is in the lanes library:

	> =lanes
	table: 00698298

Wait wait wait, what is it with all these numbers? All I wanted to do was look at what is inside the luasql.sqlite3 table. Now there's an easy solution for these types of situations:

	> see(lanes)
	.ABOUT[5]           ._M[9]              ._NAME              ._PACKAGE
	.gen(...)           .genatomic(linda, key, initial_val)     .genlock(linda, key,N)
	.linda()            .timer(linda, key, a, period)

	Metatable
	.

Oooh, now that's fancy. Notice how tables are listed with their size and functions with their parameters. Even functions with variable numbers parameters (...) are parsed correctly. Notice too that the metatables are listed as well. In this case, the lanes library contains a single __index element. Other metamethods are mapped as follows:

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

But what if you just want to look inside of an indexed table without just listing all of the keys? See.lua can do it too:

	> see{1,2,3,4,5,6,7,8,9,10}
	{1, 2, 3, 4, 5, 6, 7, 8, 9, 10}

and with key vars:

	> see{1,2,3,see=see}
	.see(object, query)
	{1, 2, 3}

That's right, see(see) introspect itself. We can also chain introspection lookups.

	> self = see{1,2,3,see=see}
	.see(object, query)
	{1, 2, 3}
	> self.see()
	@see
	function(object, query)

We can also supply an optional query into see to refine our results. For example, suppose that we want to only see functions related to tan in the mathematics library, we can simply do the following:

	> see(math, "tan")
	.atan(?)            .atan2(?)           .tan(?)             .tanh(?)

Voila, pretty neat isn't it?
