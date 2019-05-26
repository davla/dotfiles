# For complete documentation of this file, please see Geany's main documentation
[styling]
# Edit these in the colorscheme .conf file instead
default=default
comment=comment
commentline=comment_line
commentdoc=comment_line_doc
number=number
word=keyword
string=string
character=character
literalstring=string_2
preprocessor=preprocess
operator=operator
identifier=identifier
stringeol=string_eol
function_basic=function
function_other=function
coroutines=class
word5=keyword_1
word6=keyword_2
word7=keyword_3
word8=keyword_4
label=label

[keywords]

# all items must be in one line

keywords=and break do else elseif end for function goto if in local not or repeat return then until while

# Basic functions

function_basic=_ALERT arg assert call collectgarbage coroutine debug dofile dostring error _ERRORMESSAGE foreach foreachi _G gcinfo getfenv getmetatable globals _INPUT io ipairs load loadfile loadlib loadstring math module newtype next os _OUTPUT pairs pcall print _PROMPT rawequal rawget rawset require select setfenv setmetatable sort _STDERR _STDIN _STDOUT string table tinsert tonumber tostring tremove type unpack _VERSION xpcall

# String and table functions

function_other=byte char dump find format gfind gmatch gsub len lower match rep reverse sub upper strbyte strchar strfind string.byte string.char string.dump string.find string.format string.gfind string.gmatch string.gsub string.len string.lower string.match string.rep string.reverse string.sub string.upper strlen strlower strrep strsub strupper table.concat table.foreach table.foreachi table.getn table.insert table.maxn table.remove table.setn table.sort

# Math, Coroutines, I/O & system facilities

coroutines=abs acos asin atan atan2 ceil cos deg exp floor frexp ldexp log log10 math.abs math.acos math.asin math.atan math.atan2 math.ceil math.cos math.cosh math.deg math.exp math.floor math.fmod math.frexp math.huge math.ldexp math.log math.log10 math.max math.min math.mod math.modf math.pi math.pow math.rad math.random math.randomseed math.sin math.sinh math.sqrt math.tan math.tanh max min mod rad random randomseed sin sqrt appendto clock closefile coroutine.create coroutine.resume coroutine.running coroutine.status coroutine.wrap coroutine.yield date difftime execute exit flush getenv io.close io.flush io.input io.lines io.open io.output io.popen io.read io.stderr io.stdin io.stdout io.tmpfile io.type io.write openfile os.clock os.date os.difftime os.execute os.exit os.getenv os.remove os.rename os.setlocale os.time os.tmpname package.cpath package.loaded package.loadlib package.path package.preload package.seeall close read readfrom remove rename seek setlocale time tmpfile tmpname write writeto tan

# user definable keywords

# Special values

user1=false nil true

# Wikilibs

user2=string.cc string.interp string.fu string.trim frame frame.args mw mw.loadData mw.clone table.search w.interp w.trim

# geanylua API

user3=geany.activate geany.appinfo geany.banner geany.basename geany.batch geany.byte geany.caller geany.caret geany.choose geany.close geany.confirm geany.copy geany.count geany.cut geany.dirlist geany.dirname geany.dirsep geany.documents geany.fileinfo geany.filename geany.find geany.fullpath geany.height geany.input geany.keycmd geany.keygrab geany.launch geany.length geany.lines geany.match geany.message geany.navigate geany.newfile geany.open geany.optimize geany.paste geany.pickfile geany.pluginver geany.rectsel geany.rescan geany.rowcol geany.save geany.scintilla geany.script geany.select geany.selection geany.signal geany.stat geany.text geany.timeout geany.wkdir geany.word geany.wordchars geany.xsel geany.yield checkbox color file font group heading hr label new option password radio run select text textarea dialog.checkbox dialog.color dialog.file dialog.font dialog.group dialog.heading dialog.hr dialog.label dialog.new dialog.option dialog.password dialog.radio dialog.run dialog.select dialog.text dialog.textarea comment data groups has keys new remove value keyfile.comment keyfile.data keyfile.groups keyfile.has keyfile.keys keyfile.new keyfile.remove keyfile.value

user4=

[settings]

# default extension used when saving files

extension=lua

# the following characters are these which a "word" can contains, see documentation
#wordchars=_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789

# single comments, like # in this file

comment_single=--

# multiline comments

comment_open=--[[
comment_close=--]]

# set to false if a comment character/string should start at column 0 of a line, true uses any
# indentation of the line, e.g. setting to true causes the following on pressing CTRL+d
	#command_example();
# setting to false would generate this
#	command_example();
# This setting works only for single line comments

comment_use_indent=true

# context action command (please see Geany's main documentation for details)

context_action_cmd=

[indentation]
#width=4
# 0 is spaces, 1 is tabs, 2 is tab & spaces
#type=1

[build_settings]
# %f will be replaced by the complete filename
# %e will be replaced by the filename without extension
# (use only one of it at one time)
compiler=
run_cmd=lua "%f"
