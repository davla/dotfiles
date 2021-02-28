#!/usr/bin/env sh

# This script installs sway compositor and its configuration

# This doesn't work if this script is sourced
. "$(dirname "$0")/../.env"

#######################################
# Installing sway
#######################################

yay -S alacritty checkupdates+aur clipman dex grimshot i3blocks-git \
    i3blocks-contrib-git i3-volume mako-git rust sway sway-launcher-desktop \
    ttf-nerd-fonts-symbols wdisplays wev wl-clipboard
sudo cargo install --root /usr/local swayfocus

#######################################
# Installing sway dotfiles
#######################################

dotdrop install -p sway
