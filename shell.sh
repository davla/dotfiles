#!/usr/bin/env sh

# This script sets up shells, namely zsh and bash

#######################################
# zsh
#######################################

# installing zsh dotfiles and executing related scripts
cd $DOTDROP_DIR || exit
pipenv run bash dotdrop.sh install -c "$DOTDROP_CONFIG" -p zsh || exit
cd - > /dev/null || exit
