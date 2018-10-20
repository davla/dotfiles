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

cp Support/startup/*.service /etc/systemd/system
find Support/startup -name '*.service' -exec basename '{}' '.service' \; \
    | xargs echo systemctl enable

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

cp Support/shell/.bash_profile "$HOME"
cp Support/startup/*.desktop "$HOME/.config/autostart"
