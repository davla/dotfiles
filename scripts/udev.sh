#!/usr/bin/env sh

# This script sets up udev. This entails:
# - Installing the rules
# - Adding the passed users to the groups used by the udev rules.

# This doesn't work if this script is sourced
. "$(dirname "$0")/lib.sh"

#######################################
# Install udev rules
#######################################

print_info 'Install udev rules'
dotdrop install -p udev

#######################################
# Add user to groups
#######################################

for HID_USER in "$@"; do
    print_info "Add user '$HID_USER' to groups"
    usermod -a -G hid,input "$HID_USER"
done
