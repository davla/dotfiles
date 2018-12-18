#!/usr/bin/env bash

# This script makes some additional networking setup. In particular, it adds
# some local and remote hosts IP in /etc/host and it installs a script to
# disable Wi-Fi when cabled connections are active.

#####################################################
#
#                   Variables
#
#####################################################

# Absolute path of this script's parent directory
PARENT_DIR="$(dirname "${BASH_SOURCE[0]}")"
LIB_DIR="$PARENT_DIR/lib"

#####################################################
#
#                   Privileges
#
#####################################################

# Checking for root privileges: if don't have them, recalling this script with
# sudo
if [[ $EUID -ne 0 ]]; then
    echo 'This script needs to be run as root'
    sudo bash "${BASH_SOURCE[0]}" "$@"
    exit 0
fi

#####################################################
#
#                   Local hosts
#
#####################################################

# Adding local resources and a marker for frequently
# accessed remote websites
grep 'memorione' /etc/hosts &> /dev/null || echo -n "
192.168.1.3     memorione
192.168.0.11        raspberry
192.168.0.1		router

# $REMOTE_RESOURCES_MARKER
" >> /etc/hosts

#####################################################
#
#           Wi-Fi management script
#
#####################################################

DISPATCHERS_PATH='/etc/NetworkManager/dispatcher.d'

# Copying the NetworkManager dispatch script to the right location
cp "$LIB_DIR/network/"* "$DISPATCHERS_PATH"

# Setting the right permissions and ownership for dispatcher scripts
chown -R 'root:root' "$DISPATCHERS_PATH"
chmod -R u+w,ga-w,u-s,+x "$DISPATCHERS_PATH"

#####################################################
#
#                   Remote hosts
#
#####################################################

host-refresh
