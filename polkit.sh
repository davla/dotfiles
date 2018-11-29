#!/usr/bin/env bash

# This script sets up PolicyKit related matters, such
# as adding custom policy files and configurations.

#####################################################
#
#                   Variables
#
#####################################################

# Absolute path of polkit files
POLKIT_DIR="$(readlink -f Support/polkit)"

#####################################################
#
#                   Functions
#
#####################################################

# This function copies the files matching the given
# pattern, if they exist, from the polkit store
# directory to the provided destination, creating this
# if not existing.a
#
# Arguments:
#   - $1: Source files pattern.
#   - $2: Destination directory.
function copy-if-exists {
    local PATTERN="$1"
    local DEST="$2"

    mkdir -p "$DEST"
    find "$POLKIT_DIR" -maxdepth 1 -type f -name "$PATTERN" \
        -exec ln -s '{}' "$DEST" \;
}

#####################################################
#
#                   Privileges
#
#####################################################

# Checking for root privileges: if don't
# have them, recalling this script with sudo
if [[ $EUID -ne 0 ]]; then
    echo 'This script needs to be run as root'
    sudo bash "$0" "$@"
    exit 0
fi

#####################################################
#
#                   Policies
#
#####################################################

copy-if-exists '*.policy' '/usr/share/polkit-1/actions'

#####################################################
#
#                   Configurations
#
#####################################################

copy-if-exists '*.conf' '/etc/polkit-1/localauthority.conf.d'
