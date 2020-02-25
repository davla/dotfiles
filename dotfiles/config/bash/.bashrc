#!/usr/bin/env bash

# This script initializes bash interactive shells

# {{@@ header() @@}}

#######################################
# Loading configuration paths
#######################################

# shellcheck disable=2027,2140
source "{{@@ dotdirs_file | home_abs2var @@}}"

#######################################
# Loading environment variables
#######################################

source "$BDOTDIR/.bashenv"

#######################################
# Loading plugins
#######################################

source "$BDOTDIR/plugins/init.sh"

#######################################
# Loading themes
#######################################

source "$BDOTDIR/theme/init.sh"

#######################################
# Loading aliases
#######################################

source "$BDOTDIR/aliases.sh"

#######################################
# Loading functions
#######################################

source "$BDOTDIR/functions.sh"

#######################################
# Misc
#######################################

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000
HISTFILE="$BDOTDIR/.bash_history"

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
# if ! shopt -oq posix; then
#   if [ -f /usr/share/bash-completion/bash_completion ]; then
#     . /usr/share/bash-completion/bash_completion
#   elif [ -f /etc/bash_completion ]; then
#     . /etc/bash_completion
#   fi
# fi
