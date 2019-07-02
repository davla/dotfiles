#!/usr/bin/env bash

# This script performs some syntax fixes (both grammar and code) on Pokémon
# Central Wiki

source "$HOME/.bash_envvars"

#####################################################
#
#                   Functions
#
#####################################################

# This function executes a fix on all the pages of the wiki, never asking for
# confirmation and suppressing any output. In case of error, it logs an error
# message and exits the whole script.
#
# Arguments:
#   - $1: The name of the fix to be executed.
function run-fix {
    local FIX_NAME="$1"

    python pwb.py replace -pt:1 -start:! -always -fix:"$FIX_NAME" &> /dev/null

    if [[ $? -ne 0 ]]; then
        logger -p local0.err -t FIXES Error
        exit 1
    fi
}

#####################################################
#
#                   Replacements
#
#####################################################

cd "$PYWIKIBOT_DIR" || exit 1

# Grammar
run-fix 'grammar'

# Case-sensitive names
run-fix 'names-case-sensitive'

# Case-insensitive names
run-fix 'names-case-insensitive'

# Obsolete template removal
run-fix 'obsolete-templates'

logger -p local0.info -t FIXES Fixed
