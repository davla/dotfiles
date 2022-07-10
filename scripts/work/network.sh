#!/usr/bin/env sh

# This script sets up frequently visited host IP caching in /etc/hosts

# This doesn't work if this script is sourced
. "$(dirname "$0")/../lib.sh"

#######################################
# Install dotfiles
#######################################

print_info 'Install network configuration'
dotdrop install -p network

#######################################
# Add frequently visisted hosts
#######################################

print_info 'Add frequently visited hosts'
host-refresh --info --journald off --color on
