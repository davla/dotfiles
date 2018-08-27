#!/usr/bin/env bash

# This script performs some syntax fixes (both grammar and code) on Pokémon
# Central Wiki

source "$HOME/.bash_envvars"

#####################################################
#
#                   Functions
#
#####################################################

# This function logs an error message and exits in case the last command
# terminated with an error.
function exit-if-error {
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
python pwb.py replace -pt:1 -start:! -fix:grammar &> /dev/null
exit-if-error

# Case-sensitive names
python pwb.py replace -pt:1 -start:! -fix:names-case-sensitive &> /dev/null
exit-if-error

# Case-insensitive names
python pwb.py replace -pt:1 -start:! -fix:names-case-insensitive &> /dev/null
exit-if-error

# Code
python pwb.py replace -pt:1 -start:! -fix:obsolete-templates &> /dev/null
exit-if-error
