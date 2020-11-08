#!/usr/bin/env sh

# This script sets up my work machine just enough to make it workable with.
# Namely:
#   - $1: Mounts the shared directories
#   - $2: Unencrypts git secrets with the shared GPG key

#######################################
# Mounting shared directories
#######################################

echo '\e[32m[INFO]\e[0m Mounting shared directory'
mkdir -p "$HOME/mounts"
sudo /usr/bin/vmhgfs-fuse .host:/ "$HOME/mounts" -o subtype=vmhgfs-fuse,allow_other

#######################################
# Unencrypting git secrets
#######################################

echo '\e[32m[INFO]\e[0m Importing shared GPG key'
gpg --import $HOME/mounts/win-repos/gpg-pvt.asc

echo '\e[32m[INFO]\e[0m Revealing git secrets'
git secret reveal
