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
        yay -S --needed alacritty autorandr dunst i3blocks i3-gaps i3-volume \
            picom python-aiostream python-docopt python-i3ipc thunar
        ;;

    'debian')
        sudo apt-get install alacritty autorandr dunst i3 i3blocks picom \
            python3-aiostream python3-docopt python3-i3ipc thunar
        ;;
esac

#######################################
# Install i3-gaps
#######################################

[ "$DISTRO" = 'debian' ] && {
    print_info 'Install i3 gaps'
    I3_GAPS_DIR='/opt/i3-gaps'

    [ ! -d "$I3_GAPS_DIR" ] && sudo git clone \
        'https://github.com/maestrogerardo/i3-gaps-deb.git' "$I3_GAPS_DIR"

    cd "$I3_GAPS_DIR" || exit
    sudo ./i3-gaps-deb
    cd - > /dev/null 2>&1 || exit
}

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
