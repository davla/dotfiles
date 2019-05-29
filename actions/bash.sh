#!/usr/bin/env bash

# This script initializes the bash dotfiles setup.

#######################################
# Loading environment
#######################################

# The shell environment needs to be loaded manually, rather than by the shell
# itself: indeed the dotfiles are not set up yet, as this very script is meant
# to do so, meaning that some errors would occur when the shell sources them.

. "$HOME/.dotdirs"
. "$BDOTDIR/.bashenv"

#######################################
# Initializing $BDOTDIR
#######################################

mkdir -p "${BDOTDIR:?}/cache"

#######################################
# Initializing cache
#######################################

fasd --init bash-hook bash-ccomp bash-ccomp-install > "${BDOTDIR:?}/cache/fasd"
