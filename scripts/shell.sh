#!/usr/bin/env sh

# This script sets up shells, namely zsh and bash

. ./.env

#######################################
# Dependencies
#######################################

sudo apt-get install bash bash-completion dash zsh

#######################################
# Dotfiles
#######################################

dotdrop --user both install -p shell

#######################################
# Default shell
#######################################

ZSH_PATH="$(which zsh)"
chsh -s "$ZSH_PATH"
sudo chsh -s "$ZSH_PATH"
