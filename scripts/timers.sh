#!/usr/bin/env sh

# This script sets up systemd timers for both root and unprivileged users. This
# includes, besides copying the systemd unit files in the appropriate location:
#   - Linking units shared between root and unprivileged users within their
#     respective search path
#   - Activating and starting the timers

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
printf '\e[32m[INFO]\e[0m Retrieve system units\n'
ROOT_UNITS="$(dotdrop_files 'timers' 'root' | grep -E '\.(service|timer)$')"

# Shared timers and services (between root and unprivileged users)
printf '\e[32m[INFO]\e[0m Retrieve shared units\n'
SHARED_UNITS="$(echo "$ROOT_UNITS" | grep '^/etc/systemd/share/')"

# Root timers
printf '\e[32m[INFO]\e[0m Retrieve root timers\n'
ROOT_TIMERS="$(echo "$ROOT_UNITS" | grep '\.timer$' | xargs -n 1 basename)"

# Shared timers (between root and unprivileged users)
printf '\e[32m[INFO]\e[0m Retrieve shared timers\n'
SHARED_TIMERS="$(echo "$SHARED_UNITS" | grep '\.timer$' | xargs -n 1 basename)"

# User timers
printf '\e[32m[INFO]\e[0m Retrieve user timers\n'
USER_TIMERS="$(dotdrop_files 'timers' | grep '\.timer$' \
    | xargs -rn 1 basename)"

#######################################
# Root and shared timers
#######################################

# Install root and shared timers
printf '\e[32m[INFO]\e[0m Install system timers and dependencies\n'
dotdrop install -p timers -U root

# Link shared timers and services in root search path
# No quotes around $SHARED_UNITS as the spaces should split arguments
printf '\e[32m[INFO]\e[0m Link shared timers in system search path\n'
# shellcheck disable=2086
sudo systemctl link $SHARED_UNITS

# Enable and start timers (both root and shared)
printf '\e[32m[INFO]\e[0m Enable and start system and shared timers for '
echo 'system'
echo "$ROOT_TIMERS" | xargs sudo systemctl enable --now

#######################################
# User timers
#######################################

# Link shared timers in user search path
# No quotes around $SHARED_UNITS as the spaces should split arguments
printf '\e[32m[INFO]\e[0m Link shared timers in user search path\n'
# shellcheck disable=2086
systemctl --user link $SHARED_UNITS

# Enable and start shared timers
printf '\e[32m[INFO]\e[0m Enable and start shared timers for user\n'
echo "$SHARED_TIMERS" | xargs systemctl --user enable --now

# There might be no user timers altogether
[ -z "$USER_TIMERS" ] && exit

# Install user timers
printf '\e[32m[INFO]\e[0m Install user timers and dependencies\n'
dotdrop install -p timers

# Enable and start user timers
printf '\e[32m[INFO]\e[0m Enable and start user timers\n'
echo "$USER_TIMERS" | xargs systemctl --user enable --now
