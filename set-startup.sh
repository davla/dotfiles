#!/usr/bin/env bash

# This script sets up jobs to be run on boot, both root and user

#####################################################
#
#                   Variables
#
#####################################################

ROOT_JOBS=(
    'underclock 55 | logger -p local0.info -t UNDERCLOCK &'
)

#####################################################
#
#                   Root jobs
#
#####################################################

#########################
# Boot root commands, append to /etc/rc.local
#########################

# Line number of "exit 0" in /etc/rc.local
RC_LOCAL_LINE=$(grep -n -x 'exit 0' /etc/rc.local | cut -d':' -f 1)

# Decreasing line number to insert before "exit 0"
RC_LOCAL_LINE=$(( RC_LOCAL_LINE - 1 ))

# Empty line before custom commands
sudo sed -i "$RC_LOCAL_LINE i\\ " /etc/rc.local
RC_LOCAL_LINE=$(( RC_LOCAL_LINE + 1 ))

# Writing jobs to /etc/rc.local
for COMMAND in "${ROOT_JOBS[@]}"; do
    if ! grep "$COMMAND" /etc/rc.local &> /dev/null; then
        sudo sed -i "$RC_LOCAL_LINE i\\$COMMAND" /etc/rc.local
        RC_LOCAL_LINE=$(( $RC_LOCAL_LINE + 1 ))
    fi
done

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
