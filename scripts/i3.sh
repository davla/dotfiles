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
        yay -S --needed autorandr dunst i3blocks i3 i3-volume qt5ct picom \
            thunar xdg-desktop-portal xdg-desktop-portal-gtk
        if [ "$HOST" = 'personal' ]; then
            yay -S --needed python-aiostream python-docopt python-i3ipc
        fi
        ;;

    'debian')
        sudo apt-get install autorandr dunst i3 i3blocks qt5ct picom thunar \
            xdg-desktop-portal xdg-desktop-portal-gtk
        if [ "$HOST" = 'personal' ]; then
            sudo apt-get install python3-aiostream python3-docopt python3-i3ipc
        fi
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
    | cut -d ',' -f 1 | cut -d '_' -f 2 \
    | xargs systemctl --user add-wants i3-session.target
