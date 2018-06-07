#!/usr/bin/env bash

# This script sets up my raspberry pi

#####################################################
#
#               Installing packages
#
#####################################################

sudo cp Support/raspberry/testing.list /etc/apt/sources.list.d

apt-get update
# apt-get remove raspi-copies-and-fills
apt-get install git

#####################################################
#
#           Enabling SSH root login
#
#####################################################

sed -i -E 's/#.+PermitRootLogin .+$/PermitRootLogin yes/' /etc/ssh/sshd_config

#####################################################
#
#           Setting terminal colors
#
#####################################################

bash terminal-setup.sh 'raspberry'
