#!/usr/bin/env sh

# This script installs i3 window manager and its configuration

# This doesn't work if this script is sourced
. "$(dirname "$0")/../.dotfiles-env"

#######################################
# Installing i3
#######################################

case "$DISTRO" in
    'arch')
        yay -S autorandr dunst i3blocks i3-gaps i3-volume picom thunar \
            xfce4-terminal
        ;;

    'debian')
        sudo apt-get install autorandr dunst i3 i3blocks picom thunar \
            xfce4-terminal
        sudo apt-get purge i3status
        ;;
esac

#######################################
# Installing i3-gaps
#######################################

[ "$DISTRO" = 'debian' ] && {
    I3_GAPS_DIR='/opt/i3-gaps'

    [ ! -d "$I3_GAPS_DIR" ] && sudo git clone \
        'https://github.com/maestrogerardo/i3-gaps-deb.git' "$I3_GAPS_DIR"

    cd "$I3_GAPS_DIR" || exit
    sudo ./i3-gaps-deb
    cd - > /dev/null 2>&1 || exit
}

#######################################
# Installing i3 dotfiles
#######################################

dotdrop install -p i3 -U both

#######################################
# Enabling startup systemd services
#######################################

dotdrop files -bG -p i3 2> /dev/null | grep service \
    | cut -d ',' -f 1 | cut -d '_' -f 2 \
    | xargs systemctl --user add-wants i3-session.target
