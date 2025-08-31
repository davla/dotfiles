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
# eza / ls
#######################################

{%@@ set eza_colors = join_file_lines(dotfiles_dir + 'eza_colors',
    separator = ':', skip_marker = '#') @@%}
export EZA_COLORS='{{@@ eza_colors @@}}' LS_COLORS='{{@@ eza_colors @@}}'

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
export PAGER='paginate'
export VISUAL="$EDITOR"
