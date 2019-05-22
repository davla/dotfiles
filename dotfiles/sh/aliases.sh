#!/usr/bin/env sh

# This script defines useful (or not) POSIX shell aliases

alias chuck="curl -s http://api.icndb.com/jokes/random/ | jq -r '.value.joke'"
alias l='ls -lAFh --color=auto'
alias mkdir='mkdir -p'
