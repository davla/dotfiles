#!/usr/bin/env sh

# This script initializes the POSIX shell dotfies setup.

#######################################
# Loading environment
#######################################

# The shell environment needs to be loaded manually, rather than by the shell
# itself: indeed the dotfiles are not set up yet, as this very script is meant
# to do so, meaning that some errors would occur when the shell sources them.

. "$HOME/.dotdirs"
. "$SDOTDIR/.shenv"

#######################################
# Initializing $SDOTDIR
#######################################

mkdir -p "${SDOTDIR:?}/cache"
mkdir -p "${SDOTDIR:?}/plugins/data"
mkdir -p "${SDOTDIR:?}/plugins/dotfiles"

#######################################
# Initializing cache
#######################################

thefuck --alias > "${SDOTDIR:?}/cache/thefuck"
fasd --init posix-alias > "${SDOTDIR:?}/cache/fasd"
