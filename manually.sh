#!/usr/bin/env bash

# This script installs some applications manually, because they're
# not in any repository.

#####################################################
#
#                   Privileges
#
#####################################################

# Checking for root privileges: if don't
# have them, recalling this script with sudo
if [[ $EUID -ne 0 ]]; then
    echo 'This script needs to be run as root'
    sudo bash $0 $@
    exit 0
fi

#####################################################
#
#               CPU temp throttle
#
#####################################################

TEMP_THROTTLE_ARCH='temp-throttle.zip'
TEMP_THROTTLE_EXEC='/usr/local/sbin/underclock'

wget 'https://github.com/Sepero/temp-throttle/archive/stable.zip' -O \
    "$TEMP_THROTTLE_ARCH"

# Unzipping only the shellscript to stdout
# and redirecting to /sbin/underclock
unzip -p "$TEMP_THROTTLE_ARCH" '*.sh' > "$TEMP_THROTTLE_EXEC"
chmod +x "$TEMP_THROTTLE_EXEC"
rm "$TEMP_THROTTLE_ARCH"
