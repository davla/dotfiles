#!/usr/bin/env sh

# This script sets up networking, namely cabled network connection parameters
# and hostname.

. ./.env

#######################################
# Installing dotfiles
#######################################

dotdrop install -p network

#######################################
# Applying changes
#######################################

systemctl restart systemd-networkd
