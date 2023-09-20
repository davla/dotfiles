#!/usr/bin/env bash

# This script configures and loads bash plugins

# {{@@ header() @@}}

#######################################
# Inheriting from POSIX shell
#######################################

source "$SDOTDIR/interactive/plugins/shared.sh"

{%@@ if distro_id == 'arch' -@@%}

#######################################
# command-not-found
#######################################

source /usr/share/doc/pkgfile/command-not-found.bash

{%@@ endif -@@%}

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
