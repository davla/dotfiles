#!/usr/bin/env sh

# This script initializes the POSIX shell dotfies setup.
#
# Arguments:
#   - $1: The file defining the POSIX shell configuration directory path.

#######################################
# Arguments processing
#######################################

SDOTDIR_FILE="${1:?}"

#######################################
# Loading configuration paths
#######################################

# The shell configuration paths need to be loaded manually, rather than by the
# shell itself. This is because the dotfiles are indeed not set up yet, as this
# very script is meant to do so.

. "$SDOTDIR_FILE"

#######################################
# Creating symbolic links
#######################################

# POSIX shell has some non-configurable startup file paths, like
# $HOME/.profile. Here, symbolic links are created from those paths to the
# actual files in the bash configuration directory.

ln -sf "${SDOTDIR:?}/profile" "$HOME/.profile"

#######################################
# Initializing $SDOTDIR
#######################################

mkdir -p "${SDOTDIR:?}/cache"
mkdir -p "${SDOTDIR:?}/plugins/data"
mkdir -p "${SDOTDIR:?}/plugins/dotfiles"

#######################################
# Initializing cache
#######################################

# thefuck --alias > "${SDOTDIR:?}/cache/thefuck"
fasd --init posix-alias > "${SDOTDIR:?}/cache/fasd"
