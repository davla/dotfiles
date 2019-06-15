#!/usr/bin/env sh

# This script sets up networking. It installs the network manager, a script
# to disable Wi-Fi when cabled connection is available and it adds frequently
# visited hosts IPs to /etc/hosts

. ./.env

#######################################
# Installing the network manager
#######################################

apt-get install network-manager-gnome

#######################################
# Installing dotfiles
#######################################

dotdrop install -p network

# Setting the right permissions and ownership for Wi-Fi dispatcher scripts
chown -R 'root:root' /etc/NetworkManager/dispatcher.d/
chmod -R u+w,ga-w,u-s,+x /etc/NetworkManager/dispatcher.d/

#######################################
# Adding frequently visisted hosts
#######################################

host-refresh
