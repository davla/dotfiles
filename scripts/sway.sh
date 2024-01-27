#!/usr/bin/env sh

# This script installs sway compositor and its configuration

# This doesn't work if this script is sourced
. "$(dirname "$0")/lib.sh"

#######################################
# Install sway
#######################################

print_info 'Install sway'
yay -S --needed clipman gnome-themes-extra grimshot i3blocks-git \
    i3blocks-contrib-git i3-volume mako-git python-aiostream python-docopt \
    python-i3ipc qt5ct sway swayidle sway-launcher-desktop ttf-font-icons \
    udiskie wdisplays wev wl-clipboard xdg-desktop-portal \
    xdg-desktop-portal-gtk xdg-desktop-portal-wlr
sudo cargo install --root /usr/local swayfocus

#######################################
# Install sway dotfiles
#######################################

print_info 'Install sway dotfiles'
dotdrop install -p sway -U both

#######################################
# Enable startup systemd services
#######################################

print_info 'Enable sway systemd services'
dotdrop files -bG -p sway -U both 2> /dev/null | grep service \
    | cut -d ',' -f 2 | cut -d ':' -f 2 | xargs -n 1 basename \
    | xargs systemctl --user add-wants sway-session.target
