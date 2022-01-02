#!/usr/bin/env sh

# This script sets up networking, namely:
#   - Cabled network connection parameters
#   - Hostname
#   - Frequently visited host IP caching in /etc/hosts setup

# This doesn't work if this script is sourced
. "$(dirname "$0")/../../.dotfiles-env"

#######################################
# Installing dotfiles
#######################################

echo '\e[32m[INFO]\e[0m Installing network configuration'
dotdrop install -p network

#######################################
# Applying changes
#######################################

echo '\e[32m[INFO]\e[0m Restarting network daemon'
systemctl restart systemd-networkd

#######################################
# Adding frequently visisted hosts
#######################################

echo '\e[32m[INFO]\e[0m Adding frequently visited hosts'
host-refresh --info --journald off --color on
