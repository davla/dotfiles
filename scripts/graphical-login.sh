#!/usr/bin/env sh

# This script installs a graphical login manager (LightDM) and configures it.

. ./.env

#######################################
# Installing LightDM
#######################################

apt-get install lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings

#######################################
# Installing dotfiles
#######################################

dotdrop install -p graphical-login
