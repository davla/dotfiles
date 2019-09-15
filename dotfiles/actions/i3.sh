#!/usr/bin/env sh

# This script installs i3 customization dependencies

#######################################
# i3 config dependencies
#######################################

sudo apt-get install dex i3blocks
sudo apt-get purge i3status
sudo mr -d /opt/i3-volume checkout
sudo mr -d /opt/i3-volume install

#######################################
# i3 blocks dependencies
#######################################

sudo apt-get install aptitude bash gnome-keyring lm-sensors python3-keyring
sudo mr -d /opt/i3blocks-contrib checkout
sudo mr -d /opt/i3blocks-contrib install
