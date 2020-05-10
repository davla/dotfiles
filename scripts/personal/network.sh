#!/usr/bin/env sh

# This script sets up network utilities: it installs a GNOME-network-manager
# script that disables Wi-Fi when cabled connection is available; it adds
# local hosts to /etc/hosts; and it adds frequently visited hosts IPs to
# /etc/hosts

. ./.env

#######################################
# Installing the network manager
#######################################

case "$DISTRO" in
    'arch')
        pacman -S network-manager-gnome
        ;;

    'debian')
        apt-get install network-manager-gnome
        ;;
esac

#######################################
# Installing dotfiles
#######################################

dotdrop install -p network-utils

# Setting the right permissions and ownership for Wi-Fi dispatcher scripts
chown -R 'root:root' /etc/NetworkManager/dispatcher.d/
chmod -R u+w,ga-w,u-s,+x /etc/NetworkManager/dispatcher.d/

#######################################
# Adding frequently visisted hosts
#######################################

host-refresh
