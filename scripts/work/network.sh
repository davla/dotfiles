#!/usr/bin/env sh

# This script sets up frequently visited host IP caching in /etc/hosts

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
