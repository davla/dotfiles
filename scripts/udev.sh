#!/usr/bin/env sh

# This script sets up udev. This entails:
# - Installing the rules
# - Adding the passed users to the groups used by the udev rules.

#######################################
# Installing udev rules
#######################################

echo '\e[32m[INFO]\e[0m Installing udev rules'
dotdrop install -p udev

#######################################
# Adding user to groups
#######################################

for HID_USER in "$@"; do
    echo "\e[32m[INFO]\e[0m Adding user '$HID_USER' to groups"
    usermod -a -G hid,input "$HID_USER"
done
