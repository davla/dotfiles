#!/usr/bin/env sh

# This script configures and loads POSIX shell plugins and tools

#######################################
# asdf
#######################################

[ "$(ps --no-headings -p "$$" -o 'comm')" != 'sh' ] && . "$ASDF_PATH/asdf.sh"

#######################################
# exa
#######################################

EXA_COLORS="$(grep -vP '(^#|^\s*$)' "$SDOTDIR/plugins/dotfiles/exa_colors" \
    | paste -sd ':')"
export EXA_COLORS

#######################################
# fasd
#######################################

export _FASD_DATA="$SDOTDIR/plugins/data/.fasd"
export _FASD_SHELL='sh'

. "$SDOTDIR/cache/fasd"

alias v='f -e vim'

#######################################
# thefuck
#######################################

. "$SDOTDIR/cache/thefuck"
