#!/usr/bin/env sh

# This script sets up shells, namely zsh and bash

#######################################
# Dependencies
#######################################

sudo apt-get install bash bash-completion dash zsh

#######################################
# Dotfiles
#######################################

dotdrop both install -p shell -f

#######################################
# Default shell
#######################################

ZSH_PATH="$(which zsh)"
chsh -s "$ZSH_PATH"
sudo chsh -s "$ZSH_PATH"
