#!/usr/bin/env bash

# This script initializes the bash dotfiles setup.
#
# Arguments:
#   - $1: The file defining the bash configuration directory path.

# This doesn't work if this script is sourced
. "$(dirname "$0")/../../bot-steps/lib.sh"

#######################################
# Input processing
#######################################

DOTDIRS_FILE="${1:?}"

#######################################
# Load environment variables
#######################################

# This script needs bash's environment variables to function correctly.
# However, they need to be loaded explicitly, because the dotfiles are indeed
# not fully set up yet, as this very script is meant to do so.

. "$DOTDIRS_FILE"
. "${BDOTDIR:?}/bashenv"

#######################################
# Create symbolic links
#######################################

# bash has some non-configurable startup file paths, like $HOME/.bashrc. Here,
# symbolic links are created from those paths to the actual files in the bash
# configuration directory.
print_info 'Link bash startup files in home directory'
ln --force --symbolic --relative "${BDOTDIR:?}/bashrc" "$HOME/.bashrc"
ln --force --symbolic --relative "${BDOTDIR:?}/bash_profile" \
    "$HOME/.bash_profile"

#######################################
# Initialize cache
#######################################

bash "$BDOTDIR/interactive/write-cache.sh" --info --journald off
