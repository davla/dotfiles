#!/usr/bin/env zsh

# This script initializes interactive zsh shells


INTERACTIVE_ZDOTDIR="$ZDOTDIR/interactive"

#######################################
# Loading plugins
#######################################

source "$INTERACTIVE_ZDOTDIR/plugins/init.zsh"

#######################################
# Loading theme
#######################################

source "$INTERACTIVE_ZDOTDIR/theme/init.zsh"

#######################################
# Loading aliases
#######################################

source "$INTERACTIVE_ZDOTDIR/aliases.zsh"

#######################################
# Loading functions
#######################################

source "$INTERACTIVE_ZDOTDIR/functions.zsh"

########################################
# Loading hooks
########################################

source "$INTERACTIVE_ZDOTDIR/hooks.zsh"

unset INTERACTIVE_ZDOTDIR
