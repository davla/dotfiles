#!/usr/bin/env sh

# This script configures and loads POSIX shell plugins and tools that are
# useful in interactive shells only

#######################################
# asdf
#######################################

[ "$(ps --no-headings -p "$$" -o 'comm')" != 'sh' ] && . "$ASDF_HOME/asdf.sh"

#######################################
# exa
#######################################

EXA_COLORS="$(grep -vP '(^#|^\s*$)' \
    "$SDOTDIR/interactive/plugins/dotfiles/exa_colors" | paste -sd ':')"
export EXA_COLORS

#######################################
# fasd
#######################################

alias v='f -e vim'
