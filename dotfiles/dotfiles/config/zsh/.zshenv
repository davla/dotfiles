#!/usr/bin/env zsh

# This script sets the environment variables for zsh

# {{@@ header() @@}}

#######################################
# Loading configuration paths
#######################################

# shellcheck disable=2027,2140
source "{{@@ dotdirs_file | replace("~", "$HOME") @@}}"

#######################################
# Inheriting from POSIX shell
#######################################

source "$SDOTDIR/.shenv"

######################################
# Antibody
######################################

export ANTIBODY_HOME="$ZDOTDIR/.antibody"
