#!/usr/bin/env sh

# {{@@ header() @@}}

# This script defines useful (or not) POSIX shell aliases

#######################################
# Core commands aliases
#######################################

alias l='ls -lAFh --color=auto'
alias mkdir='mkdir -p'
alias root='sudo -s'

#######################################
# Third-party commands aliases
#######################################

alias mr='mr -d {{@@ mr_default_dir @@}}'

#######################################
# New commands
#######################################

alias chuck="curl -s http://api.icndb.com/jokes/random/ | jq -r '.value.joke'"
