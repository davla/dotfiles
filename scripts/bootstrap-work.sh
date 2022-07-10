#!/usr/bin/env sh

# This script sets up my work machine just enough to make it workable with.
# Namely:
#   - $1: Mounts the shared directories
#   - $2: Unencrypts git secrets with the shared GPG key

# This doesn't work if this script is sourced
. "$(dirname "$0")/lib.sh"

#######################################
# Mount shared directories
#######################################

print_info 'Mount shared directory'
mkdir -p "$HOME/mounts"
sudo /usr/bin/vmhgfs-fuse .host:/ "$HOME/mounts" -o subtype=vmhgfs-fuse,allow_other

#######################################
# Unencrypt git secrets
#######################################

print_info 'Import shared GPG key'
gpg --import "$HOME/mounts/win-repos/gpg-pvt.asc"

print_info 'Reveal git secrets'
git secret reveal
