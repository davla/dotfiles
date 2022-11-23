#!/usr/bin/env sh

# This scripts contains initializaiton and configuration of plugins and tools
# that are shell-specific, and should therefore not be inherited by other
# POSIX-compliant shells. Such plugins are useful in interactive shells only.

########################################
# fasd
########################################

export _FASD_DATA="$SDOTDIR/interactive/plugins/data/.fasd"
export _FASD_SHELL='sh'

. "$SCACHEDIR/fasd"

#######################################
# thefuck
#######################################

. "$SCACHEDIR/thefuck"
