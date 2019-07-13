#!/usr/bin/env sh

# This script sets up shells, namely zsh and bash

. ./.env

#######################################
# Installing dependencies
#######################################

sudo apt-get install bash bash-completion dash exa fasd thefuck zsh xsel
sudo mr -d /opt/antibody install

#######################################
# Installing dotfiles
#######################################

dotdrop --user both install -p sh
dotdrop --user both install -p bash
dotdrop --user both install -p zsh

#######################################
# Setting default shell
#######################################

ZSH_PATH="$(which zsh)"
chsh -s "$ZSH_PATH"
sudo chsh -s "$ZSH_PATH"
