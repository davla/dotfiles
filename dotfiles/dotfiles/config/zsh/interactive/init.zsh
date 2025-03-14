#!/usr/bin/env zsh

# This script initializes interactive zsh shells

INTERACTIVE_ZDOTDIR="$ZDOTDIR/interactive"


########################################
# Configure core utils
########################################

source "$SDOTDIR/interactive/env-var-config.sh"

########################################
# Configure builtins
########################################

source "$INTERACTIVE_ZDOTDIR/builtins-config.zsh"

#######################################
# Load plugins
#######################################

source "$INTERACTIVE_ZDOTDIR/plugins/init.zsh"

#######################################
# Load aliases
#######################################

source "$INTERACTIVE_ZDOTDIR/aliases.zsh"

#######################################
# Load functions
#######################################

source "$INTERACTIVE_ZDOTDIR/functions.zsh"

########################################
# Load hooks
########################################

source "$INTERACTIVE_ZDOTDIR/hooks.zsh"


unset INTERACTIVE_ZDOTDIR
