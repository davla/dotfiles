#!/usr/bin/env sh

# This script configures and loads POSIX shell plugins and tools that are
# useful in interactive shells only

#######################################
# asdf
#######################################

[ "$(ps --no-headings -p "$$" -o 'comm')" != 'sh' ] && . "$ASDF_HOME/asdf.sh"

#######################################
# fasd
#######################################

alias v='f -e vim'
