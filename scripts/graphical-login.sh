#!/usr/bin/env sh

# This script installs a graphical login manager (LightDM) and configures it.

. ./.env

#######################################
# Installing LightDM
#######################################

case "$DISTRO" in
    'arch')
        # apt-get install lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings
        ;;

    'debian')
        apt-get install lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings
        ;;
esac

#######################################
# Installing dotfiles
#######################################

dotdrop install -p graphical-login
