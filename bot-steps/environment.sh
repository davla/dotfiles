#!/usr/bin/env sh

# This script sets up environment variables for login shells

# This doesn't work if this script is sourced
. "$(dirname "$0")/lib.sh"

########################################
# Install environment dotfiles
########################################

dotdrop -U root install -p environment

########################################
# Logout to load environment variables
########################################

prompted_logout 'Logout necessary to load new environment variables'
