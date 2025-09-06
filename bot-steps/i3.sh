#!/usr/bin/env sh

# This script installs i3 window manager and its configuration

# This doesn't work if this script is sourced
. "$(dirname "$0")/lib.sh"

#######################################
# Install i3
#######################################

print_info 'Install i3'
case "$DISTRO" in
    'arch')
        yay -S --needed autorandr dunst gnome-themes-extra hsetroot i3 \
            i3blocks i3-volume python-docopt python-i3ipc picom qt5ct rofi \
            thunar xdg-desktop-portal xdg-desktop-portal-gtk
        ;;

    'debian')
        sudo apt-get install autorandr dunst hsetroot i3 i3blocks \
            python3-docopt python3-i3ipc picom qt5ct rofi thunar \
            xdg-desktop-portal xdg-desktop-portal-gtk xfce4-power-manager
        ;;
esac

#######################################
# Install i3 dotfiles
#######################################

print_info 'Install i3 dotfiles'
dotdrop install -p i3 -U both

#######################################
# Enable startup systemd services
#######################################

print_info 'Enable i3 systemd services'
dotdrop files -bG -p i3 2> /dev/null | grep service \
    | cut --delimiter ',' --fields 1 | cut --delimiter '_' --fields 2 \
    | xargs systemctl --user add-wants i3-session.target
