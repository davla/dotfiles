#!/usr/bin/env zsh

# This script contains functions that are added as zsh hooks for both
# interactive and non-interactive shells

########################################
# Environmed loading hook
########################################

# This function is meant to be used as a chpwd hook. It simply sources any .env
# file found in the current working directory, if any
load_environment() {
    [ -f .env ] && {
        echo 'Sourcing .env'
        source .env
    }
}

add-zsh-hook chpwd load_environment

########################################
# History hooks
########################################

# This function is meant to be used as a zshaddhistory hook. It fixes my most
# common git typo, that is swapping the t and the space (e.g. gi tstatus).
gi_history_fix() {
    emulate -L zsh
    local TRIMMED_CMD="$(echo "$1" | xargs)"
    case "$TRIMMED_CMD" in
        *'gi t'*)
            local FIXED_CMD="git ${TRIMMED_CMD#'gi t'}"
            not_in_history_ignore "$FIXED_CMD" && print -s "$FIXED_CMD"
            ;;
    esac
    return 0
}

# This function is meant to be used as a zshaddhistory hook. It exits with 1 if
# the first argument matches the content of $HISTORY_IGNORE, with 0 otherwise.
not_in_history_ignore() {
    emulate -L zsh
    [[ "$(echo "$1" | xargs)" != ${~HISTORY_IGNORE} ]]
}

add-zsh-hook zshaddhistory gi_history_fix
add-zsh-hook zshaddhistory not_in_history_ignore
