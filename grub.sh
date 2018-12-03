#!/usr/bin/env bash

# This script handles grub settings; specifically it:
#	- Sets the first OS in the list as the default choice
#	- Sets the timeout to zero
#	- Sets command line options to get brightness keys to work

#####################################################
#
#                   Privileges
#
#####################################################

# Checking for root privileges: if don't have them, recalling this script with
# sudo
if [[ $EUID -ne 0 ]]; then
    echo 'This script needs to be run as root'
    sudo bash "$0" "$@"
    exit 0
fi

#####################################################
#
#                   GRUB Setup
#
#####################################################

sed -r -i 's/GRUB_DEFAULT=[0-9]+/GRUB_DEFAULT=0/g' /etc/default/grub
sed -r -i 's/GRUB_TIMEOUT=[0-9]+/GRUB_TIMEOUT=0/g' /etc/default/grub
sed -r -i 's/GRUB_CMDLINE_LINUX_DEFAULT="(.*)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 acpi_backlight=vendor"/g' \
    /etc/default/grub

update-grub
