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
echo '\e[32m[INFO]\e[0m Retrieving system units'
ROOT_UNITS="$(dotdrop_files 'timers' 'root' | grep -E '\.(service|timer)$')"

# Shared timers and services (between root and unprivileged users)
echo '\e[32m[INFO]\e[0m Retrieving shared units'
SHARED_UNITS="$(echo "$ROOT_UNITS" | grep '^/etc/systemd/share/')"

# Root timers
echo '\e[32m[INFO]\e[0m Retrieving root timers'
ROOT_TIMERS="$(echo "$ROOT_UNITS" | grep '\.timer$' | xargs -n 1 basename)"

# Shared timers (between root and unprivileged users)
echo '\e[32m[INFO]\e[0m Retrieving shared timers'
SHARED_TIMERS="$(echo "$SHARED_UNITS" | grep '\.timer$' | xargs -n 1 basename)"

# User timers
echo '\e[32m[INFO]\e[0m Retrieving user timers'
USER_TIMERS="$(dotdrop_files 'timers' | grep '\.timer$' | xargs -n 1 basename)"

#######################################
# Root timers
#######################################

# Installation
echo '\e[32m[INFO]\e[0m Installing system timers and dependencies'
dotdrop install -p timers -U root

# Linking shared timers and services in root search path
# No quotes around $SHARED_UNITS as the spaces should split arguments
echo '\e[32m[INFO]\e[0m Linking shared timers in system search path'
sudo systemctl link $SHARED_UNITS

# Enabling and starting timers
echo '\e[32m[INFO]\e[0m Enabling system and shared timers for system'
echo "$ROOT_TIMERS" | xargs sudo systemctl enable
echo '\e[32m[INFO]\e[0m Starting system and shared timers for system'
echo "$ROOT_TIMERS" | xargs sudo systemctl start

#######################################
# User timers
#######################################

# Installation
echo '\e[32m[INFO]\e[0m Installing user timers and dependencies'
dotdrop install -p timers

# Linking shared timers in user search path
# No quotes around $SHARED_UNITS as the spaces should split arguments
echo '\e[32m[INFO]\e[0m Linking shared timers in user search path'
systemctl --user link $SHARED_UNITS

# Enabling and starting timers
echo '\e[32m[INFO]\e[0m Enabling shared timers for user'
echo "$SHARED_TIMERS" | xargs systemctl --user enable
echo '\e[32m[INFO]\e[0m Starting shared timers for user'
echo "$SHARED_TIMERS" | xargs systemctl --user start
echo '\e[32m[INFO]\e[0m Enabling user timers'
echo "$USER_TIMERS" | xargs systemctl --user enable
echo '\e[32m[INFO]\e[0m Starting user timers'
echo "$USER_TIMERS" | xargs systemctl --user start
