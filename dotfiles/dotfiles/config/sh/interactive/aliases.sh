#!/usr/bin/env sh

# {{@@ header() @@}}

# This script defines some POSIX shell aliases that are useful in interactive
# shells only

#######################################
# Core commands aliases
#######################################

alias c='xsel -i -b'
alias p='xsel -o'

{%@@- if user == 'user' @@%}

alias root='sudo -s'

{%@@ elif user == 'root' @@%}
{%@@- if env['DISTRO'] == 'debian' @@%}

alias update='apt-get update && apt-get upgrade'

{%@@ endif -@@%}
{%@@ endif -@@%}

#######################################
# New commands
#######################################

alias chuck="curl -s http://api.icndb.com/jokes/random/ | jq -r '.value.joke'"

########################################
# Typos aliases
########################################

alias gl=' clear'
