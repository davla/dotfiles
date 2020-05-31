#!/usr/bin/env bash

# This script configures and loads bash plugins

# {{@@ header() @@}}

#######################################
# Inheriting from POSIX shell
#######################################

source "$SDOTDIR/plugins/init.sh"

{%@@ if env['DISTRO'] == 'arch' @@%}
#######################################
# command-not-found
#######################################

source /usr/share/doc/pkgfile/command-not-found.bash

{%@@ endif @@%}
#######################################
# fasd
#######################################

source "$BDOTDIR/cache/fasd"

#######################################
# thefuck
#######################################

# source "$BDOTDIR/cache/thefuck"
