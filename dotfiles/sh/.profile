#!/usr/bin/env sh

# This script initializes the POSIX shell

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
