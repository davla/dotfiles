#!/usr/bin/env zsh

# This script contains functions that are added as zsh hooks

########################################
# Background hooks
########################################

# This function is meant to be used as a precmd hook. It attempts running
# `git fetch` in the background each 10 times it executes.
BG_GIT_FETCH_COUNT=0
bg_git_fetch() {
    BG_GIT_FETCH_COUNT=$(( (BG_GIT_FETCH_COUNT + 1) % 10 ))
    [ "$BG_GIT_FETCH_COUNT" -eq 0 ] && (git -C "$PWD" fetch > /dev/null 2>&1 &)
}

add-zsh-hook precmd bg_git_fetch

########################################
# Environmed loading hooks
########################################

# This function is meant to be used as a chpwd hook. It sources environment
# files in the current directory, or if none are found in the root of the git
# repository, if within a git repository at all.
load_environment() {
    local ENV_FILES="$(find_dotfiles .)"
    [ -z "$ENV_FILES" ] && {
        local GIT_ROOT="$(git rev-parse --path-format=relative \
            --show-toplevel 2> /dev/null)"
        [ -n "$GIT_ROOT" ] && ENV_FILES="$(find_dotfiles "${GIT_ROOT%/}")"
    }

    for ENV_FILE in ${(ps. .)ENV_FILES}; do
        echo "Source environment file $ENV_FILE"
        source "$ENV_FILE"
    done
}

# This function finds dotfiles in a given directory. If none are found, it
# returns the empty string.
#
# Arguments:
#   - $1: The directory to scan for dotfiles
find_dotfiles() {
    echo "$1"/.(*-|)env(N)
}

add-zsh-hook chpwd load_environment

########################################
# History hooks
########################################

# This function is meant to be used as a zshaddhistory hook. It fixes my most
# common git typo, that is swapping the t and the space (e.g. gi tstatus).
gi_history_fix() {
    emulate -L zsh
    local TRIMMED_CMD="$(zsh_trim_str "$1")"
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
    [[ "$(zsh_trim_str "$1")" != ${~HISTORY_IGNORE} ]]
}

add-zsh-hook zshaddhistory gi_history_fix
add-zsh-hook zshaddhistory not_in_history_ignore

# This function trims witespaces in a string by only using zsh features.
#
# Arguments:
#   - $1: The string to be trimmed
zsh_trim_str() {
    setopt EXTENDED_GLOB
    local TMP=${1##[[:space]]##}
    echo ${TMP%%[[:space:]]##}
}
