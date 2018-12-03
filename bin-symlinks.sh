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
CMDS=(
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

# Checking for root privileges: if don't have them, recalling this script with
# sudo
if [[ $EUID -ne 0 ]]; then
    echo 'This script needs to be run as root'
    sudo bash "$0" "$@"
    exit 0
fi

#####################################################
#
#               Creating symlinks
#
#####################################################

for CMD in "${CMDS[@]}"; do
    LINK_DEST="$BIN_PATH/${CMD,,}"

    echo "Linking $CMD"

    # Removing the symbolic link we are about to create, so that it's not
    # found as an executable later
    rm "$LINK_DEST" &> /dev/null

    # Finding the command executable around the filesystem
    CMD_PATH="$(which "$CMD" || find / -type f -executable -name "$CMD" \
        | head -n 1)"

    if [[ -z "$CMD_PATH" || ! -f "$CMD_PATH" ]]; then
        echo "$CMD not found"
        continue
    fi

    ln -s "$CMD_PATH" "$LINK_DEST"

    # Setting SUID for root-owned executables
    [[ "$(stat -c %U "$CMD_PATH")" == 'root' ]] && chmod u+s "$CMD_PATH"

    echo "$CMD linked"
done
