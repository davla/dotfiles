--[[

This script allows the execution of a
"find and replace" macro written for
geany-plugin geanylua on any file

The first argument is the filename
the macro will be executed on,
the second one the name of the macro,
without '.lua' extension:

	lua geanyMacro.lua <filename> <macro name>


Deceiving the macro, that is creating a fake
geany global object

--]]

geany = {}

--[[

Getting the text from the file, rather than
from the editor, and writing into the file,
instead of the editor

--]]

geany.text = function(text)
	if not text then
		return io.open(arg[1]):read('*a')
	else
		io.open(arg[1], 'w'):write(text)
	end
end

require(arg[2])
