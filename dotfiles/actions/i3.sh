#!/usr/bin/env sh

# This doesn't work if this script is sourced
. "$(dirname "$0")"/../../.env

# This script installs i3 customization dependencies

#######################################
# i3 config dependencies
#######################################

case "$DISTRO" in
    'arch')
        yay -S dex i3blocks i3-volume
        ;;

    'debian')
        sudo apt-get install dex i3blocks
        sudo apt-get purge i3status
        sudo mr -d /opt/i3-volume -c /opt/.mrconfig checkout
        sudo mr -d /opt/i3-volume -c /opt/.mrconfig install
        ;;
esac

#######################################
# i3 blocks dependencies
#######################################

case "$DISTRO" in
    'arch')
        yay -S bash gnome-keyring lm-sensors python-keyring i3blocks-contrib
        ;;

    'debian')
        sudo apt-get install aptitude bash gnome-keyring lm-sensors \
            python3-keyring
        sudo mr -d /opt/i3blocks-contrib -c /opt/.mrconfig checkout
        sudo mr -d /opt/i3blocks-contrib -c /opt/.mrconfig install
        ;;
esac
