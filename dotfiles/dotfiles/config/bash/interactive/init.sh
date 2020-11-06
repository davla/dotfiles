#!/usr/bin/env bash

# This script initializes interactive bash shells


INTERACTIVE_BDOTDIR="$BDOTDIR/interactive"

#######################################
# Loading plugins
#######################################

source "$INTERACTIVE_BDOTDIR/plugins/init.sh"

#######################################
# Loading themes
#######################################

source "$INTERACTIVE_BDOTDIR/theme/init.sh"

#######################################
# Loading aliases
#######################################

source "$INTERACTIVE_BDOTDIR/aliases.sh"

#######################################
# Loading functions
#######################################

source "$INTERACTIVE_BDOTDIR/functions.sh"


unset INTERACTIVE_BDOTDIR
