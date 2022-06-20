#!/usr/bin/env sh

# This script sets up systemd timers for both root and unprivileged users. This
# includes, besides copying the systemd unit files in the appropriate location:
#   - Linking units shared between root and unprivileged users within their
#     respective search path
#   - Activating and starting the timers

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
        | cut -d ',' -f 2 | cut -d ':' -f 2

    unset INSTALLED_PROFILE INSTALLED_USER
}

#######################################
# Variables
#######################################

# Root timers and services
print_info 'Retrieve system units'
ROOT_UNITS="$(dotdrop_files 'timers' 'root' | grep -E '\.(service|timer)$')"

# Shared timers and services (between root and unprivileged users)
print_info 'Retrieve shared units'
SHARED_UNITS="$(echo "$ROOT_UNITS" | grep '^/etc/systemd/share/')"

# Root timers
print_info 'Retrieve root timers'
ROOT_TIMERS="$(echo "$ROOT_UNITS" | grep '\.timer$' | xargs -n 1 basename)"

# Shared timers (between root and unprivileged users)
print_info 'Retrieve shared timers'
SHARED_TIMERS="$(echo "$SHARED_UNITS" | grep '\.timer$' | xargs -n 1 basename)"

# User timers
print_info 'Retrieve user timers'
USER_TIMERS="$(dotdrop_files 'timers' | grep '\.timer$' \
    | xargs -rn 1 basename)"

#######################################
# Root and shared timers
#######################################

# Install root and shared timers
print_info 'Install system timers and dependencies'
dotdrop install -p timers -U root

# Link shared timers and services in root search path
# No quotes around $SHARED_UNITS as the spaces should split arguments
print_info 'Link shared timers in system search path'
# shellcheck disable=2086
sudo systemctl link $SHARED_UNITS

# Enable and start timers (both root and shared)
print_info 'Enable and start system and shared timers for system'
echo "$ROOT_TIMERS" | xargs sudo systemctl enable --now

#######################################
# User timers
#######################################

# Link shared timers in user search path
# No quotes around $SHARED_UNITS as the spaces should split arguments
print_info 'Link shared timers in user search path'
# shellcheck disable=2086
systemctl --user link $SHARED_UNITS

# Enable and start shared timers
print_info 'Enable and start shared timers for user'
echo "$SHARED_TIMERS" | xargs systemctl --user enable --now

# There might be no user timers altogether
[ -z "$USER_TIMERS" ] && {
    print_info 'No user timers found'
    exit
}

# Install user timers
print_info 'Install user timers and dependencies'
dotdrop install -p timers

# Enable and start user timers
print_info 'Enable and start user timers'
echo "$USER_TIMERS" | xargs systemctl --user enable --now
