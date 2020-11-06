#!/usr/bin/env zsh

# This script initializes non-interactive zsh shells

# {{@@ header() @@}}

#######################################
# Loading configuration paths
#######################################

# shellcheck disable=2027,2140
source "{{@@ dotdirs_file | home_abs2var @@}}"

#######################################
# Inheriting from POSIX shell
#######################################

source "$SDOTDIR/shenv"

######################################
# Defining Environment variables
######################################

export ANTIBODY_HOME="$ZDOTDIR/.antibody"

#######################################
# Loading aliases
#######################################

source "$ZDOTDIR/aliases.zsh"

#######################################
# Loading functions
#######################################

source "$ZDOTDIR/functions.zsh"

#######################################
# Loading theme
#######################################

source "$ZDOTDIR/theme/init.zsh"
