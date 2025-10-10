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

# Render UTF-8 characters
export LESSCHARSET='utf-8'
export LESSUTFCHARDEF='e000-f8ff:p,f0001-fffff:p'

########################################
# unzip
########################################

export UNZIP='-a -L -o'

########################################
# Widely used environment variables
########################################

export EDITOR='vim'
export PAGER='paginate'
export VISUAL="$EDITOR"
