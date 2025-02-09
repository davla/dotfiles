#!/usr/bin/env sh

# This script installs i3 customization dependencies

# This doesn't work if this script is sourced
. "$(dirname "$0")/../../.dotfiles-env"
. "$(dirname "$0")/../../scripts/lib.sh"

#######################################
# i3 config dependencies
#######################################

print_info 'Install dependencies used in the i3 config file'
case "$DISTRO" in
    'arch')
        yay -S --needed i3blocks i3-volume
        ;;

    'debian')
        sudo apt-get install i3blocks
        print_info 'Install i3-volume via github-releases'
        sudo gh-release install
        ;;
esac

#######################################
# i3 blocks dependencies
#######################################

print_info 'Install dependencies used in i3blocks scripts'
case "$DISTRO" in
    'arch')
        yay -S --needed bash i3blocks-contrib-git gnome-keyring lm-sensors \
            python-keyring
        ;;

    'debian')
        sudo apt-get install aptitude bash gnome-keyring lm-sensors \
            python3-keyring
        sudo mr -d /opt/i3blocks-contrib -c /opt/.mrconfig checkout
        sudo mr -d /opt/i3blocks-contrib -c /opt/.mrconfig install
        ;;
esac
