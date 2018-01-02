#!/usr/bin/env bash

# This script makes some executable files located around the filesystem
# available as CLI commands for a regular user, by creating symbolic
# links to them in directories in the PATH variable. Root-owned
# executables are set the SUID so as to be exeutable by regilar users.

#####################################################
#
#                   Variables
#
#####################################################

BIN_PATH='/usr/local/bin'
EXEC_NAMES=(
    'arduino'
    'halt'
    'mysql'
    'php'
    'reboot'
    'Telegram'
)

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
#               Creating symlinks
#
#####################################################

for EXEC_NAME in ${EXEC_NAMES[@]}; do
    LINK_DEST="$BIN_PATH/${EXEC_NAME,,}"

    echo "Linking $EXEC_NAME"

    # Removing the symbolic link we are about to create,
    # so that it's not found as an executable later
    rm "$LINK_DEST" &> /dev/null

    EXEC_PATH=$(which "$EXEC_NAME" || find / -type f -executable \
            -name "$EXEC_NAME" 2> /dev/null | head -n 1)

    if [[ -z "$EXEC_PATH" || ! -f "$EXEC_PATH" ]]; then
        echo "$EXEC_NAME not found"
        continue
    fi

    ln -s "$EXEC_PATH" "$LINK_DEST"
    [[ $(stat -c %U "$EXEC_PATH") == 'root' ]] && chmod u+s "$EXEC_PATH"

    echo "$EXEC_NAME linked"
done
