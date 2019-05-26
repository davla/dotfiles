# For complete documentation of this file, please see Geany's main documentation

[styling=C]

[keywords]

# all items must be in one line

primary=abstract boolean byte break case catch char class const continue debugger default delete do double each else enum export extends false final finally float for function get goto if implements import in Infinity instanceof int interface let long NaN native new null package private protected public return set short static super switch synchronized this throw throws transient true try undefined var void volatile while with yield prototype Array Boolean Date Function Math Number Object RegExp String EvalError Error RangeError ReferenceError SyntaxError TypeError URIError

secondary=decodeURI decodeURIComponent encodeURI encodeURIComponent escape eval isFinite isNaN parseFloat parseInt typeof unescape concat indexOf join lastIndexOf length pop push reverse shift slice sort splice toString unshift valueOf getDate getDay getFullYear getHours getMilliseconds getMinutes getMonth getSeconds getTime getTimezoneOffset getUTCDate getUTCDay getUTCFullYear getUTCHours getUTCMilliseconds getUTCMinutes getUTCMonth getUTCSeconds getYear parse setDate setFullYear setHours setMilliseconds setMinutes setMonth setSeconds setTime setUTCDate setUTCFullYear setUTCHours setUTCMilliseconds setUTCMinutes setUTCMonth setUTCSeconds setYear toDateString toGMTString toISOString toJSON toLocaleDateString toLocaleTimeString toString toTimeString toUTCString Math.UTC Math.E Math.LN2 Math.LN10 Math.LOG2E Math.LOG10E Math.PI Math.SQRT1_1 Math.SQRT2 Math.abs Math.acos Math.asin Math.atan Math.atan2 Math.ceil Math.cos Math.exp Math.floor Math.log Math.max Math.min Math.pow Math.random Math.round Math.sin Math.sqrt Math.tan Number.MAX_VALUE Number.MIN_VALUE Number.NEGATIVE_INFINITY Number.NaN Number.POSITIVE_INFINITY toExponential toFixed toPrecision global ignoreCase lastIndex multiline source exec test charAt charCodeAt fromCharCode localeCompare match replace search split substr substring toLocaleLowerCase toLocaleUpperCase toLowerCase toUpperCase trim appendChild attributes childNodes cloneNode firstChild getAttribute getElementById getElementsByTagName hasChildNodes innerHTML insertBefore lastChild nextSibling nodeName nodeType nodeValue parentNode previousSibling removeChild replaceChild setAttribute

[settings]

# default extension used when saving files

extension=js

# the following characters are these which a "word" can contains, see documentation
#wordchars=_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789

# single comments, like # in this file

comment_single=//

# multiline comments

comment_open=/*
comment_close=*/

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
run=
