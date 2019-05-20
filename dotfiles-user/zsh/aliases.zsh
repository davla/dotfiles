#!/usr/bin/env zsh

# This script contains useful (or not) zsh aliases

alias chuck="curl -s http://api.icndb.com/jokes/random/ | jq -r '.value.joke'"
alias l='ls -lAFh --color=auto'
