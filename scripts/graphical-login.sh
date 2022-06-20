#!/usr/bin/env sh

# This script installs a graphical login manager (LightDM) and configures it.

#######################################
# Installing LightDM
#######################################

case "$DISTRO" in
    'debian')
        apt-get install lightdm lightdm-gtk-greeter \
            lightdm-gtk-greeter-settings xserver-xorg-input-all
        ;;
esac

#######################################
# Installing dotfiles
#######################################

dotdrop install -p graphical-login
