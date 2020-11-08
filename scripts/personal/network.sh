#!/usr/bin/env sh

# This script sets up network utilities, namely:
#   - A GNOME-network-manager script that disables Wi-Fi when cabled connection
#     is available
#   - Local hosts to /etc/hosts
#   - Frequently visited host IP caching in /etc/hosts setup

# This doesn't work if this script is sourced
. "$(dirname "$0")/../../.env"

#######################################
# Installing the network manager
#######################################

echo '\e[32m[INFO]\e[0m Installing GNOME network manager'
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

echo '\e[32m[INFO]\e[0m Installing network configuration'
dotdrop install -p network

#######################################
# Adding frequently visisted hosts
#######################################

echo '\e[32m[INFO]\e[0m Adding frequently visited hosts'
host-refresh --info --journald off --color on
