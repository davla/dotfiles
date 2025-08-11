#!/usr/bin/env sh

# This script sets up the system startup, including both system and user
# startup jobs

# This doesn't work if this script is sourced
. "$(dirname "$0")/lib.sh"

#######################################
# Functions
#######################################

# This function returns the absolute paths where the files belonging to a
# dotdrop profile are installed to.
#
# Arguments:
#   - $1: The dotdrop profile whose files will be returned
#   - $2: The user the dotdrop profile belongs to. Optional, defaults to "user"
dotdrop_files() {
    INSTALLED_PROFILE="$1"
    INSTALLED_USER="${2:-user}"

    dotdrop files -bGp "$INSTALLED_PROFILE" -U "$INSTALLED_USER" 2> /dev/null \
        | cut --delimiter ',' --fields 2 | cut --delimiter ':' --fields 2

    unset INSTALLED_PROFILE INSTALLED_USER
}

#######################################
# System startup jobs
#######################################

if dotdrop -bG files -p startup -U root 2> /dev/null \
    | grep --extended-regexp --quiet --invert-match '(^[[:blank:]]*|":)$'; then
    print_info 'Install root startup jobs'
    dotdrop install -p startup -U root

    print_info 'Enable and start root systemd services'
    dotdrop_files 'startup' 'root' | grep '\.service$' \
        | xargs --no-run-if-empty sudo systemctl enable --now
else
    print_info 'No root startup jobs found'
fi

#######################################
# User startup jobs
#######################################

print_info 'Install user startup jobs'
dotdrop install -p startup -U user

print_info 'Enable and start user systemd services'
dotdrop_files 'startup' 'user' | grep '\.service$' \
    | xargs --no-run-if-empty systemctl --user enable --now
