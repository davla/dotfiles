#!/usr/bin/env sh

# This script initializes interactive POSIX shells

INTERACTIVE_SDOTDIR="$SDOTDIR/interactive"


########################################
# Environment variables configuration
########################################

. "$INTERACTIVE_SDOTDIR/env-var-config.sh"

#######################################
# Load plugins
#######################################

. "$INTERACTIVE_SDOTDIR/plugins/shared.sh"
. "$INTERACTIVE_SDOTDIR/plugins/specific.sh"

#######################################
# Load aliases
#######################################

. "$INTERACTIVE_SDOTDIR/aliases.sh"

#######################################
# Load functions
#######################################

. "$INTERACTIVE_SDOTDIR/functions.sh"


unset INTERACTIVE_SDOTDIR
