#!/usr/bin/env sh

# This scripts contains initializaiton and configuration of plugins and tools
# that is shell-specific, and should therefore not be inherited by other
# POSIX-compliant shells.

########################################
# fasd
########################################

export _FASD_DATA="$SDOTDIR/plugins/data/.fasd"
export _FASD_SHELL='sh'

. "$SDOTDIR/cache/fasd"

#######################################
# thefuck
#######################################

. "$SDOTDIR/cache/thefuck"
