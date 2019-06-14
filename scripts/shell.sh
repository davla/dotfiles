#!/usr/bin/env sh

# This script sets up shells, namely zsh and bash

. ./.env

#######################################
# Installing dependencies
#######################################

sudo apt-get install bash bash-completion dash zsh

#######################################
# Installing dotfiles
#######################################

dotdrop --user both install -p shell

#######################################
# Setting default shell
#######################################

ZSH_PATH="$(which zsh)"
chsh -s "$ZSH_PATH"
sudo chsh -s "$ZSH_PATH"
