#!/usr/bin/env bash

# This script sets up jobs to be run on boot, both root and user

#####################################################
#
#                   Variables
#
#####################################################

# Absolute path of this script's parent directory
PARENT_DIR="$(dirname "${BASH_SOURCE[0]}")"
LIB_DIR="$PARENT_DIR/lib"

# Absolute path of lib directory for startup
STARTUP_LIB_DIR="$(readlink -f "$LIB_DIR/startup")"

# Used to mark the custom mount points in /etc/fstab
CUSTOM_MOUNTS_MARKER='# Custom mount points'

# Shell globs of the .desktop files for the startup jobs to be delayed
DELAYED=('*npass*.desktop')

# THe directory where Xfce keeps startup applications
XFCE_AUTOSTART_DIR="$HOME/.config/autostart"

#####################################################
#
#                   Root jobs
#
#####################################################

#########################
# Systemd services
#########################

sudo cp "$STARTUP_LIB_DIR/"*.service /etc/systemd/system

# Enabling all the services, by getting their name from their .service file
# shellcheck disable=SC2038
find "$STARTUP_LIB_DIR" -name '*.service' -exec basename '{}' '.service' \; \
    | xargs sudo systemctl enable

#########################
# /etc/fstab setup
#########################

# Only adding the custom mount points if they're not already there
if ! grep "$CUSTOM_MOUNTS_MARKER" /etc/fstab &> /dev/null; then

    # Raspberry nfs
    RASPBERRY_ROOT="$HOME/Files/Raspberry"

    mkdir -p "$RASPBERRY_ROOT"
    echo "
$CUSTOM_MOUNTS_MARKER

raspberry:/ $RASPBERRY_ROOT nfs users,dev,exec,noauto,rw,suid 0 0" \
        | sudo tee -a /etc/fstab > /dev/null
fi

#####################################################
#
#                   User jobs
#
#####################################################

####################################
# Delaying some autostart jobs
####################################

# Need the for loop since every DELAYED item needs to be passed to find, as it
# can match multiple files
for JOB in "${DELAYED[@]}"; do
    # Prefixing the Exec command with sleep. The first sed pattern makes the
    # script idempotent, as it doesn't add sleep when it's already there.
    find "$XFCE_AUTOSTART_DIR" -name "$JOB" -exec sed -i -E \
        "/Exec=.*sleep/! s/Exec=(.+)/Exec=sh -c 'sleep 2s \&\& \1'/g" '{}' \;
done

####################################
# Setting startup jobs
####################################

ln -sf "$STARTUP_LIB_DIR/xinitrc" "$HOME/.config/xfce4"
ln -sf "$STARTUP_LIB_DIR/"*.desktop "$XFCE_AUTOSTART_DIR"
