#!/usr/bin/env bash

# This script sets up jobs to be run on boot, both root and user

#####################################################
#
#                   Root jobs
#
#####################################################

#########################
# Systemd services
#########################

sudo cp Support/startup/*.service /etc/systemd/system
# shellcheck disable=SC2038
find Support/startup -name '*.service' -exec basename '{}' '.service' \; \
    | xargs sudo systemctl enable

#########################
# /etc/fstab setup
#########################

CUSTOM_MOUNTS_MARKER='# Custom mount points'

if ! grep "$CUSTOM_MOUNTS_MARKER" /etc/fstab &> /dev/null; then
    echo "$CUSTOM_MOUNTS_MARKER" | sudo tee -a /etc/fstab &> /dev/null

    # Raspberry nfs
    RASPBERRY_ROOT="$HOME/Files/Raspberry"

    mkdir -p "$RASPBERRY_ROOT"
    echo "raspberry:/ $RASPBERRY_ROOT nfs users,dev,exec,noauto,rw,suid 0 0" \
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

XFCE_AUTOSTART_DIR="$HOME/.config/autostart"

# Shell globs of the jobs to be delayed
DELAYED=('*npass*.desktop')

# Need the for loop since every DELAYED item needs to be passed to find, as it
# can match multiple files
for JOB in "${DELAYED[@]}"; do
    # The first sed pattern makes the script idempotent
    find "$XFCE_AUTOSTART_DIR" -name "$JOB" -exec sed -i -E \
        "/Exec=.*sleep/! s/Exec=(.+)/Exec=sh -c 'sleep 2s \&\& \1'/g" '{}' \;
done

####################################
# Setting startup jobs
####################################

# Absolute path of startup configuration directory
STARTUP_CONF_DIR="$(readlink -f Support/startup/)"

ln -sf "$STARTUP_CONF_DIR/xinitrc" "$HOME/.config/xfce4"
ln -sf "$STARTUP_CONF_DIR/"*.desktop "$XFCE_AUTOSTART_DIR"
