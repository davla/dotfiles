#!/usr/bin/env sh

# This script sets up shells, namely zsh and bash

# This doesn't work if this script is sourced
. "$(dirname "$0")/lib.sh"

#######################################
# Install dependencies
#######################################

print_info 'Install system dependencies'
case "$DISTRO" in
    'arch')
        yay -S --needed bash bash-completion dash eza fasd sheldon thefuck zsh
        ;;

    'debian')
        sudo apt-get install bash bash-completion dash eza fasd thefuck zsh \
            xsel

        print_info 'Install sheldon via github-releases'
        dotdrop -U root install -p github-releases
        sudo gh-release install
        ;;
esac

#######################################
# Install dotfiles
#######################################

print_info 'Install system zsh configuration'
dotdrop -U root install -p zsh-system

print_info 'Install POSIX shell configuration'
dotdrop -U both install -p sh
print_info 'Install bash configuration'
dotdrop -U both install -p bash
print_info 'Install zsh configuration'
dotdrop -U both install -p zsh

#######################################
# Set default shell
#######################################

ZSH_PATH="$(which zsh)"
print_info "Set default shell to zsh for $USER"
chsh --shell "$ZSH_PATH"
print_info 'Set default shell to zsh for root'
sudo chsh --shell "$ZSH_PATH"
