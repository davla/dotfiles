#!/usr/bin/env bash

# This script initializes interactive bash shells


INTERACTIVE_BDOTDIR="$BDOTDIR/interactive"


########################################
# Environment variables configuration
########################################

source "$SDOTDIR/interactive/env-var-config.sh"

#######################################
# Load plugins
#######################################

source "$INTERACTIVE_BDOTDIR/plugins/init.sh"

#######################################
# Load aliases
#######################################

source "$INTERACTIVE_BDOTDIR/aliases.sh"

#######################################
# Load functions
#######################################

source "$INTERACTIVE_BDOTDIR/functions.sh"


unset INTERACTIVE_BDOTDIR
