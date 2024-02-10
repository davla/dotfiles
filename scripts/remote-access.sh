#!/usr/bin/env sh

# This script sets up remote access configuration, such as ssh and nfs

# This doesn't work if this script is sourced
. "$(dirname "$0")/lib.sh"

########################################
# Set up remote access configuration
########################################

print_info 'Install dotfiles'
dotdrop install -p remote-access

########################################
# Setup systemd services
########################################

print_info 'Start nfs and ssh servers and enable them at boot'
systemctl enable --now nfs-server sshd

########################################
# Set up users and passwords
########################################

# This script is only executed from here. However, it's a quite complex one
# with a few gotchas, hence it's kept in a separate files.
exec sh -e scripts/users.sh
