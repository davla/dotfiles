#!/usr/bin/env bash

# This script initializes the bash dotfiles setup.
#
# Arguments:
#   - $1: The file defining the bash configuration directory path.

#######################################
# Arguments processing
#######################################

BDOTDIR_FILE="${1:?}"

#######################################
# Loading configuration paths
#######################################

# The shell configuration paths need to be loaded manually, rather than by the
# shell itself. This is because the dotfiles are indeed not set up yet, as this
# very script is meant to do so.

. "$BDOTDIR_FILE"

#######################################
# Creating symbolic links
#######################################

# bash has some non-configurable startup file paths, like $HOME/.bashrc. Here,
# symbolic links are created from those paths to the actual files in the bash
# configuration directory.

ln -sf "${BDOTDIR:?}/.bashrc" "$HOME/.bashrc"
ln -sf "${BDOTDIR:?}/.bash_profile" "$HOME/.bash_profile"

#######################################
# Initializing $BDOTDIR
#######################################

mkdir -p "${BDOTDIR:?}/cache"

#######################################
# Initializing cache
#######################################

# thefuck --alias > "${BDOTDIR:?}/cache/thefuck"
fasd --init bash-hook bash-ccomp bash-ccomp-install > "${BDOTDIR:?}/cache/fasd"
