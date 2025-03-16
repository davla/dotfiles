#!/usr/bin/env sh

# This script installs a graphical login manager (LightDM) and configures it.

# This doesn't work if this script is sourced
. "$(dirname "$0")/../.dotfiles-env"
. "$(dirname "$0")/lib.sh"

#######################################
# Install LightDM
#######################################

print_info 'Install graphical login manager'
case "$DISTRO" in
    'debian')
        apt-get install lightdm lightdm-gtk-greeter \
            lightdm-gtk-greeter-settings xserver-xorg-input-all
        ;;
esac

#######################################
# Install dotfiles
#######################################

print_info 'Install graphical login manager dotfiles'
dotdrop install -p graphical-login
