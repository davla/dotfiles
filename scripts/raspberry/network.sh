#!/usr/bin/env sh

# This script sets up networking, namely:
#   - Cabled network connection parameters
#   - Hostname
#   - Frequently visited host IP caching in /etc/hosts setup

# This doesn't work if this script is sourced
. "$(dirname "$0")/../lib.sh"

#######################################
# Install dotfiles
#######################################

print_info 'Install network configuration'
dotdrop install -p network

#######################################
# Apply changes
#######################################

print_info 'Restart network daemon'
systemctl restart systemd-networkd

#######################################
# Add frequently visisted hosts
#######################################

print_info 'Add frequently visited hosts'
host-refresh --info --journald off --color on
