# bash-util
Utility bash scripts

## Summary
This is my little collection of bash scripts written over the
years to automate all sort of tasks, and to make up for my bad
memory (*"I've already run into this problem two years ago. How
did I fix this back then? 😕"*). At some point I decided to overcome
my shame an publish it on the Internet, hoping that someone else
can ~~copy-paste~~ find inspiration for their own tasks, or more
likely when struggling against Linux. Enjoy 😄

## Stylistic choices
Some pieces of code might appear a bit dumb, and definitely not clever.
In most of the cases though, they are the result of a stylistic
choice, or of my obsession for consistency 😱

### Quoting
Quoting is a good practice in bash. You can't deny that. Nonetheless,
it's verbose, and often unnecessary.
```bash
"$HOME/non-spaced-path"
```
In this example, quoting is superfluous: the `$HOME` variable can't
have spaces, and the extra text in the quotes contains none either.
Single-quoting strings is also not mandatory in the syntax, but it's
definitely friendly, since every one of us also programs in other
language where it is. So, I adopt my own convention, and stick to
these obsessively:

- Only use double quotes when a variable is involved.
- Always double-quote variables usages.
- Always double-quote variables interpolations.
- Always single-quote echo messages.
- Always single-quote function arguments.
- Always single-quote URLs.
- Single-quote riles of course only apply if no variable is involved
😝.
- Never quote constant paths.

### Tests
Using the bash double-brackets built-in `[[ ]]` is generally
considered bad practice, for portability issues; however, I find
the `test` built-in nasty and terribly unreadable: operators are
not the same as both C-like languages and English words, and wildcard
expansions behaves differently than in the rest of the language.
Also, at the end of the day, portability is not a concern here: these
scripts are targeted for personal computers, that normally use bash
as default shell; and every file is prefixed with a bash shebang.
