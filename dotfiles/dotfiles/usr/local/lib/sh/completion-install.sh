#!/usr/bin/env sh

# This file contains utility functions to install shell completions
#
# {{@@ header() @@}}

#######################################
# Imports
#######################################

. "{{@@ logger_path @@}}"

########################################
# Variables
########################################

BASH_COMPLETIONS_DIR='/usr/local/share/bash-completion/completions'
ZSH_COMPLETIONS_DIR='/usr/local/share/zsh/site-functions'

########################################
# Functions
########################################

# This function installs a bash completion file received via STDIN.
#
# Inputs:
#   - STDIN: The content of the bash completion.
#   - $1: The name for the completion file. If it's a path, only the base name
#         is used.
install_bash_completion() (
    COMPLETION_FILE="$(basename "$1")"

    log_info "Install bash completion for $COMPLETION_FILE"
    mkdir --parents "$BASH_COMPLETIONS_DIR"
    COMPLETION_PATH="$BASH_COMPLETIONS_DIR/$COMPLETION_FILE"
    log_debug "Write bash completion at $COMPLETION_PATH"
    cat > "$COMPLETION_PATH"
)

# This function installs a zsh completion file received via STDIN.
#
# Inputs:
#   - STDIN: The content of the zsh completion.
#   - $1: The name for the completion file. If it's a path, only the base name
#         is used. An '_' prefix is added if not already present.
install_zsh_completion() (
    COMPLETION_FILE="$(basename "$1")"

    log_info "Install zsh completion for $COMPLETION_FILE"
    mkdir --parents "$ZSH_COMPLETIONS_DIR"
    COMPLETION_PATH="$ZSH_COMPLETIONS_DIR/_${COMPLETION_FILE##_}"
    log_debug "Write zsh completion at $COMPLETION_PATH"
    cat > "$COMPLETION_PATH"
)

# This function removes the bash completion for the given command
#
# Arguments:
#   - $1: The command to remove the bash completion for
remove_bash_completion() (
    CMD="$1"

    log_info "Remove bash completion for $CMD"
    # No --recursive, won't remove the whole bash completion directory if $CMD
    # is empty
    rm --force "$BASH_COMPLETIONS_DIR/$CMD"
)

# This function removes the zsh completion for the given command
#
# Arguments:
#   - $1: The command to remove the zsh completion for
remove_zsh_completion() (
    CMD="$1"

    log_info "Remove zsh completion for $CMD"
    rm --force "$ZSH_COMPLETIONS_DIR/_${CMD##_}"
)
