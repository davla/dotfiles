#!/usr/bin/env sh

# This script sets up shells, namely zsh and bash

. ./.env

#######################################
# Installing dependencies
#######################################

case "$DISTRO" in
    'arch')
        yay -S antibody-bin bash bash-completion dash exa fasd thefuck zsh
        ;;

    'debian')
        sudo apt-get install bash bash-completion dash exa fasd thefuck zsh \
            xsel
        sudo mr -d /opt/antibody install
        ;;
esac

#######################################
# Installing dotfiles
#######################################

dotdrop -U both install -p sh
dotdrop -U both install -p bash
dotdrop -U both install -p zsh

#######################################
# Setting default shell
#######################################

ZSH_PATH="$(which zsh)"
chsh -s "$ZSH_PATH"
sudo chsh -s "$ZSH_PATH"
