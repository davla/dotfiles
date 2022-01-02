#!/usr/bin/env sh

# This script installs sway compositor and its configuration

# This doesn't work if this script is sourced
. "$(dirname "$0")/../.dotfiles-env"

#######################################
# Installing sway
#######################################

yay -S alacritty checkupdates+aur clipman dex grimshot i3blocks-git \
    i3blocks-contrib-git i3-volume mako-git rust sway sway-launcher-desktop \
    ttf-nerd-fonts-symbols udiskie wdisplays wev wl-clipboard
sudo cargo install --root /usr/local swayfocus

#######################################
# Installing sway dotfiles
#######################################

dotdrop install -p sway -U both

#######################################
# Enabling startup systemd services
#######################################

dotdrop files -bG -p sway -U both 2> /dev/null | grep service \
    | cut -d ',' -f 2 | cut -d ':' -f 2 | xargs -n 1 basename \
    | xargs systemctl --user add-wants sway-session.target
