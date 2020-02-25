#!/usr/bin/env sh

# This script initializes the POSIX shell

# {{@@ header() @@}}

#######################################
# Loading configuration paths
#######################################

# shellcheck disable=2027,2140
. "{{@@ dotdirs_file | home_abs2var @@}}"

#######################################
# Loading environment variables
#######################################

. "$SDOTDIR/.shenv"

#######################################
# Loading plugins
#######################################

. "$SDOTDIR/plugins/init.sh"

#######################################
# Loading aliases
#######################################

. "$SDOTDIR/aliases.sh"

#######################################
# Loading functions
#######################################

. "$SDOTDIR/functions.sh"
