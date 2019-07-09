#!/usr/bin/env sh

# {{@@ header() @@}}

# This script defines useful (or not) POSIX shell aliases

#######################################
# Core commands aliases
#######################################

alias c='xsel -i -b'
alias mkdir='mkdir -p'
alias p='xsel -o'
alias root='sudo -s'

#######################################
# Third-party commands aliases
#######################################

alias ls='exa'
alias mr='mr -d {{@@ mr_default_dir @@}}'
alias tree='exa -T'

#######################################
# New commands
#######################################

alias chuck="curl -s http://api.icndb.com/jokes/random/ | jq -r '.value.joke'"
