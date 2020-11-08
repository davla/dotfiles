#!/usr/bin/env sh

# This script installs i3 window manager and its configuration

. ./.env

#######################################
# Installing i3
#######################################

case "$DISTRO" in
    'arch')
        yay -S autorandr compton dex dunst i3blocks i3-gaps i3-volume thunar \
            xfce4-terminal
        ;;

    'debian')
        sudo apt-get install autorandr dunst i3 i3blocks compton dex thunar \
            xfce4-terminal
        sudo apt-get purge i3status
        ;;
esac

#######################################
# Installing i3-gaps
#######################################

[ "$DISTRO" = 'debian' ] && {
    I3_GAPS_DIR='/opt/i3-gaps'

    sudo git clone https://github.com/maestrogerardo/i3-gaps-deb.git "$I3_GAPS_DIR"
    cd "$I3_GAPS_DIR" || exit
    sudo ./i3-gaps-deb
    cd - > /dev/null 2>&1 || exit
}

#######################################
# Installing i3 dotfiles
#######################################

dotdrop install -p i3
