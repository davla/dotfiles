#!/usr/bin/env bash

# This script configures and loads bash plugins

# {{@@ header() @@}}

#######################################
# Inheriting from POSIX shell
#######################################

source "$SDOTDIR/interactive/plugins/shared.sh"

#######################################
# fasd
#######################################

export _FASD_DATA="$BDOTDIR/interactive/plugins/data/.fasd"
export _FASD_SHELL='bash'

source "$BCACHEDIR/fasd"

#######################################
# thefuck
#######################################

source "$BCACHEDIR/thefuck"
