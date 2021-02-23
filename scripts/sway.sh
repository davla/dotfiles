#!/usr/bin/env sh

# This script installs sway compositor and its configuration

# This doesn't work if this script is sourced
. "$(dirname "$0")/../.env"

#######################################
# Installing sway
#######################################

yay -S alacritty dex grimshot i3-volume mako-git rust sway \
    sway-launcher-desktop ttf-nerd-fonts-symbols wdisplays wev
sudo cargo install --root /usr/local swayfocus

#######################################
# Installing sway dotfiles
#######################################

dotdrop install -p sway
