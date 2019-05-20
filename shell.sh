#!/usr/bin/env sh

# This script sets up shells, in particular zsh and bash

#######################################
# zsh
#######################################

# zsh-variables
export ZSH_CACHE="$HOME/.zsh/cache"

# installing zsh dotfiles and executing related scripts
cd $DOTDROP_DIR || exit
pipenv run bash dotdrop.sh -c "$DOTDROP_CONFIG" -p zsh
cd - > /dev/null || exit

unset ZSH_CACHE
