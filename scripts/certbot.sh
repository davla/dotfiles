#!/usr/bin/env bash

# This script installs TSL certificates for my Afraid.org DNS domain, if they
# are not alreay present. The certificates are installed via certbot, using
# standalone mode: this is why the script will pause, prompting the user to
# open port 80, so that the temporary server will work.

#####################################################
#
#                   Privileges
#
#####################################################

# Checking for root privileges: if don't have them, recalling this script with
# sudo
if [[ $EUID -ne 0 ]]; then
    echo 'This script needs to be run as root'
    sudo bash "${BASH_SOURCE[0]}" "$@"
    exit 0
fi

#####################################################
#
#               TSL certificate setup
#
#####################################################

if ! certbot certificates 2> /dev/null | grep 'Found' &> /dev/null; then
    read -p 'Open port 80 as the TSL certificates are being installed'
    certbot certonly --standalone -d 'maze0.hunnur.com' \
        -m 'truzzialrogo@gmx.com'
fi
