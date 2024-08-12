#!/usr/bin/env sh

# This file contains configuration for UNIX core utilities and shell builtins
# when used interactively (e.g. cd, ls...)
#
# {{@@ header() @@}}

########################################
# cd
########################################

export CDPATH="{{@@ ['.', code_root, cd_path ] | select('defined')
    | map('tilde2home') | join(':') @@}}"

#######################################
# exa
#######################################

# Technically this is not a UNIX core utility, but I use it as an ls
# replacement. ^_^

EXA_COLORS="$(grep --invert-match --perl-regexp '(^#|^\s*$)' \
        "$SDOTDIR/interactive/dotfiles/exa_colors" \
    | paste --serial --delimiters ':')"
export EXA_COLORS
