#!/usr/bin/env sh

# This script sets up shells, namely zsh and bash

# This doesn't work if this script is sourced
. "$(dirname "$0")/../.env"

#######################################
# Installing dependencies
#######################################

echo '\e[32m[INFO]\e[0m Installing system dependencies'
case "$DISTRO" in
    'arch')
        yay -S antibody-bin bash bash-completion dash exa fasd thefuck zsh
        ;;

    'debian')
        sudo apt-get install bash bash-completion dash exa fasd thefuck zsh \
            xsel
        sudo mr -d /opt/antibody -c /opt/.mrconfig install
        ;;
esac

#######################################
# Installing dotfiles
#######################################

echo '\e[32m[INFO]\e[0m Installing POSIX shell configuration'
dotdrop -U both install -p sh
echo '\e[32m[INFO]\e[0m Installing bash configuration'
dotdrop -U both install -p bash
echo '\e[32m[INFO]\e[0m Installing zsh configuration'
dotdrop -U both install -p zsh

#######################################
# Setting default shell
#######################################

ZSH_PATH="$(which zsh)"
echo "\e[32m[INFO]\e[0m Setting default shell to zsh for $USER"
chsh -s "$ZSH_PATH"
echo '\e[32m[INFO]\e[0m Setting default shell to zsh for root'
sudo chsh -s "$ZSH_PATH"
