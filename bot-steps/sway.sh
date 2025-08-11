#!/usr/bin/env sh

# This script installs sway compositor and its configuration

# This doesn't work if this script is sourced
. "$(dirname "$0")/lib.sh"

#######################################
# Install sway
#######################################

print_info 'Install sway'
yay -S --needed cargo-binstall clipman gnome-themes-extra i3blocks-git \
    i3blocks-contrib-git i3-volume mako python-docopt python-i3ipc qt5ct sway \
    sway-contrib sway-launcher-desktop swayidle ttf-font-icons udiskie \
    wdisplays wev wl-clipboard xdg-desktop-portal xdg-desktop-portal-gtk \
    xdg-desktop-portal-wlr
sudo cargo binstall --root /usr/local swayfocus

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
    | cut --delimiter ',' --fields 2 | cut --delimiter ':' --fields 2 \
    | xargs --max-args 1 basename \
    | xargs systemctl --user add-wants sway-session.target
