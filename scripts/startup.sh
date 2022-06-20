#!/usr/bin/env sh

# This script sets up the system startup, including both system and user
# startup jobs

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
        | cut -d ',' -f 2 | cut -d ':' -f 2

    unset INSTALLED_PROFILE INSTALLED_USER
}

#######################################
# System startup jobs
#######################################

if dotdrop -bG files -p startup -U root 2> /dev/null \
    | grep -Ev '(^[[:blank:]]*|":)$'; then
    printf '\e[32m[INFO]\e[0m Install root startup jobs\n'
    dotdrop install -p startup -U root

    printf '\e[32m[INFO]\e[0m Enable and start root systemd services\n'
    dotdrop_files 'startup' 'root' | grep -E '\.service$' \
        | xargs --no-run-if-empty sudo systemctl enable --now
else
    printf '\e[32m[INFO]\e[0m No root startup jobs found\n'
fi

#######################################
# User startup jobs
#######################################

printf '\e[32m[INFO]\e[0m Install user startup jobs\n'
dotdrop install -p startup -U user

printf '\e[32m[INFO]\e[0m Enable and start user systemd services\n'
dotdrop_files 'startup' 'user' | grep -E '\.service$' \
    | xargs --no-run-if-empty systemctl --user enable --now
