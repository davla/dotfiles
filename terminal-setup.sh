#!/usr/bin/env bash

# This script sets, for both user and root, the content and colors of the
# terminal prompt and the text in the title of terminal windows, Colors vary
# based on the specified host.

# Arguments:
#   - $1: The host used to choose the colors. Defaults to 'local'.
#       So far, one of:
#       - local
#       - raspberry

# The system is based on a prompt-setting script, exporting a function meant to
# be used as PROMPT_COMMAND. This function reads a bunch of variables that
# define the colorscheme from a file in the user home directory.

#####################################################
#
#                   Variables
#
#####################################################

# Absolute path of this script's parent directory
PARENT_DIR="$(dirname "${BASH_SOURCE[0]}")"
LIB_DIR="$PARENT_DIR/lib"

# Absolute path of lib directory for shell
SHELL_LIB_DIR="$(readlink -f "$LIB_DIR/shell")"

# Whether this script is being run in a sudo environment. Used to stop
# recursion due to self-sourcing in set-prompt-theme.
[[ -n "$(printenv | grep SUDO)" ]] && IS_SUDO='true' || IS_SUDO='false'

# This file's path
THIS_FILE="$(readlink -f "${BASH_SOURCE[0]}")"

#####################################################
#
#                   Parameters
#
#####################################################

# Host to choose the colors for
HOST="${1:-local}"

#####################################################
#
#                   Functions
#
#####################################################

# This function sets up user-specific configuraton for the prompt. This means
# that is sets the colorscheme and sets the prompt command in the user
# .bashrc file. It is expected to be executed as the user the setup is being
# made for.
#
# Arguments:
#   - $1: The absolute path of the colorscheme file to be used.
function __set-prompt-theme {
    local COLORSCHEME_FILE="$1"

    # Linking the passed colorscheme in the user home, where the prompt-setting
    # script expects it to be.
    ln -sf "$COLORSCHEME_FILE" "$HOME/.prompt-colorscheme.sh"

    # Appending a few lines to the user .bashrc, only if not aready there.
    # These lines source the prompt-setting script and set PROMPT_COMMAND.
    grep '.set-prompt.sh' "$HOME/.bashrc" &> /dev/null || echo "
# Setting custom prompt theme
[[ -f /usr/local/lib/set-prompt.sh ]] && . /usr/local/lib/set-prompt.sh
PROMPT_COMMAND='set-prompt'" >> "$HOME/.bashrc"
}

# This function sets the prompt and the terminal title of a given user for
# a certain host
#
# Arguments:
#   - $1: The host the prompt should be set for
#   - $2: The user home directory
function set-prompt-theme {
    local HOST="$1"
    local USER="$2"

    # Colorscheme file for the passed user on the given host
    COLORSCHEME_FILE="$SHELL_LIB_DIR/prompt-colorscheme-$HOST-$USER.sh"

    # We need to execute a few commands in the user environment. Escaping
    # everything in the string passed as the bash command is unconvenient.
    # Therefore, the commands have been grouped into an auxiliary function,
    # made available by sourcing this very file.
    sudo -u "$USER" bash -c "
        source \"$THIS_FILE\"
        __set-prompt-theme \"$COLORSCHEME_FILE\"
    "
}

#####################################################
#
#               User-independent setup
#
#####################################################

# Linking the prompt-setting file to a system-wide location, to make it easily
# available for all users
sudo ln -sf "$SHELL_LIB_DIR/set-prompt.sh" /usr/local/lib/set-prompt.sh

#####################################################
#
#                       Root
#
#####################################################

# Only calling set-prompt-theme when not run as sudo. This tames the recursion
# owed to self-sourcing in set-prompt-theme.
[[ "$IS_SUDO" == 'false' ]] && set-prompt-theme "$HOST" 'root'

#####################################################
#
#                       User
#
#####################################################

# Only calling set-prompt-theme when not run as sudo. This tames the recursion
# owed to self-sourcing in set-prompt-theme.
[[ "$IS_SUDO" == 'false' ]] && set-prompt-theme "$HOST" "$USER"
