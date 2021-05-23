#!/usr/bin/env sh

# This script initializes interactive POSIX shells


INTERACTIVE_SDOTDIR="$SDOTDIR/interactive"


#######################################
# Loading plugins
#######################################

. "$INTERACTIVE_SDOTDIR/plugins/shared.sh"
. "$INTERACTIVE_SDOTDIR/plugins/specific.sh"

#######################################
# Loading aliases
#######################################

. "$INTERACTIVE_SDOTDIR/aliases.sh"

#######################################
# Loading functions
#######################################

. "$INTERACTIVE_SDOTDIR/functions.sh"

{%@@ if user == 'user' -@@%}

########################################
# Console login
########################################

start_graphical_session

{%@@ endif -@@%}


unset INTERACTIVE_SDOTDIR
