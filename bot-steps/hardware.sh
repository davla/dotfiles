#!/usr/bin/env sh

# This script sets up hardware tweaks. This entails:
# - Installing hardware-related configuration files.
# - Adding the passed users to the groups used by the udev rules.

# This doesn't work if this script is sourced
. "$(dirname "$0")/lib.sh"

#######################################
# Install udev rules
#######################################

print_info 'Install hardware dotfiles'
dotdrop install -p hardware

#######################################
# Add user to groups
#######################################

for HID_USER in "$@"; do
    print_info "Add user '$HID_USER' to groups"
    usermod --append --groups hid,input "$HID_USER"
done
