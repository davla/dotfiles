#!/usr/bin/env sh

# This file contains environment variables used to configure some commands when
# used interactively.
#
# {{@@ header() @@}}

{%@@ set dotfiles_dir = dirname(_dotfile_sub_abs_src) + '/dotfiles/' -@@%}

########################################
# cd
########################################

export CDPATH="{{@@ ['.', code_root, cd_path ] | select('defined')
    | map('tilde2home') | join(':') @@}}"

#######################################
# exa / ls
#######################################

{%@@ set exa_colors = join_file_lines(dotfiles_dir + 'exa_colors',
    separator = ':', skip_marker = '#') @@%}
export EXA_COLORS='{{@@ exa_colors @@}}' LS_COLORS='{{@@ exa_colors @@}}'

########################################
# grep
########################################

export GREP_COLORS='{{@@ join_file_lines(dotfiles_dir + 'grep_colors',
    separator = ':', skip_marker = '#') @@}}'

########################################
# jq
########################################

export JQ_COLORS='{{@@ join_file_lines(dotfiles_dir + 'jq_colors',
    separator = ':', skip_marker = '#') @@}}'

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
