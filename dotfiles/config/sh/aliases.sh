#!/usr/bin/env sh

# {{@@ header() @@}}

# This script defines useful (or not) POSIX shell aliases

#######################################
# Core commands aliases
#######################################

alias c='xsel -i -b'
alias mkdir='mkdir -p'
alias p='xsel -o'

{%@@- if user == 'user' @@%}

alias root='sudo -s'

{%@@ elif user == 'root' @@%}
{%@@- if env['DISTRO'] == 'debian' @@%}

alias update='apt-get update && apt-get upgrade'

{%@@ endif -@@%}
{%@@ endif -@@%}

#######################################
# Third-party commands aliases
#######################################

alias ls='exa'
alias tree='exa -T'

#######################################
# New commands
#######################################

alias chuck="curl -s http://api.icndb.com/jokes/random/ | jq -r '.value.joke'"
