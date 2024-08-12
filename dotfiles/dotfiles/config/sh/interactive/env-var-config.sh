#!/usr/bin/env sh

# This file contains environment variables used to configure some commands when
# used interactively.
#
# {{@@ header() @@}}

########################################
# cd
########################################

export CDPATH="{{@@ ['.', code_root, cd_path ] | select('defined')
    | map('tilde2home') | join(':') @@}}"

#######################################
# exa / ls
#######################################

EXA_COLORS="$(grep --invert-match --perl-regexp '(^#|^\s*$)' \
        "$SDOTDIR/interactive/dotfiles/exa_colors" \
    | paste --serial --delimiters ':')"
export EXA_COLORS LS_COLORS="$EXA_COLORS"

########################################
# grep
########################################

GREP_COLORS="$(grep --invert-match --perl-regexp '(^#|^\s*$)' \
        "$SDOTDIR/interactive/dotfiles/grep_colors" \
    | paste --serial --delimiters ':')"
export GREP_COLORS

########################################
# jq
########################################

JQ_COLORS="$(grep --invert-match --perl-regexp '(^#|^\s*$)' \
        "$SDOTDIR/interactive/dotfiles/jq_colors" \
    | paste --serial --delimiters ':')"
export JQ_COLORS

########################################
# less
########################################

export LESS='--chop-long-lines --RAW-CONTROL-CHARS'

########################################
# unzip
########################################

export UNZIP='-a -L -o'

########################################
# Widely used environment variables
########################################

export EDITOR='vim'
export PAGER="less --chop-long-lines --no-init --quit-if-one-screen \
    --RAW-CONTROL-CHARS"
export VISUAL="$EDITOR"
