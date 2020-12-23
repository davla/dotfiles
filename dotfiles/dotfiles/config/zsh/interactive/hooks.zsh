#!/usr/bin/env zsh

# This script contains functions that are added as zsh hooks for both
# interactive and non-interactive shells

########################################
# Environmed loading hook
########################################

# This function is meant to be used as a chpwd hook. It simply sources any .env
# file found in the current working directory, if any
function load_environment {
    [ -f .env ] && {
        echo 'Sourcing .env'
        source .env
    }
}

# Adding load_environment as a chpwd hook
add-zsh-hook chpwd load_environment

########################################
# History hooks
########################################

# This function is mean to be used as a zshaddhistory hook. It exits with 1 if
# the first argument matches the content of $HISTORY_IGNORE, with 0 otherwise.
not_in_history_ignore() {
    emulate -L zsh
    [[ "$(echo "$1" | xargs)" != ${~HISTORY_IGNORE} ]]
}

add-zsh-hook zshaddhistory not_in_history_ignore
