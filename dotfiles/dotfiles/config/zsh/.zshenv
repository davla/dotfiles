#!/usr/bin/env zsh

# This script initializes non-interactive zsh shells

# {{@@ header() @@}}

#######################################
# Loading configuration paths
#######################################

# shellcheck disable=2027,2140
source "{{@@ shell_dirs_file | home_abs2var @@}}"

#######################################
# Inheriting from POSIX shell
#######################################

source "$SDOTDIR/shenv"

#######################################
# Loading aliases
#######################################

source "$ZDOTDIR/aliases.zsh"

#######################################
# Loading functions
#######################################

source "$ZDOTDIR/functions.zsh"
