#!/usr/bin/env bash

# This script sets up jobs to be run on boot, both root and user

#####################################################
#
#                   Variables
#
#####################################################

ROOT_JOBS=(
    'underclock 55 &'
)

#####################################################
#
#                   Root jobs
#
#####################################################

#########################
# Boot root commands, appendd to /etc/rc.local
#########################

# Line number of "exit 0" in /etc/rc.local
RC_LOCAL_LINE=$(grep -n -x 'exit 0' /etc/rc.local | awk -F : '{ print $1 }')

# Decreasing line number to insert before "exit 0"
RC_LOCAL_LINE=$(( $RC_LOCAL_LINE - 1 ))

# Empty line before custom commands
sudo sed -i "$RC_LOCAL_LINE i\\ " /etc/rc.local
RC_LOCAL_LINE=$(( $RC_LOCAL_LINE + 1 ))

# Writing jobs to /etc/rc.local
for COMMAND in "${ROOT_JOBS[@]}"; do
    sudo sed -i "$RC_LOCAL_LINE i\\$COMMAND" /etc/rc.local
    RC_LOCAL_LINE=$(( $RC_LOCAL_LINE + 1 ))
done

#########################
# /etc/fstab setup
#########################

echo '# Custom mount points' | sudo tee -a /etc/fstab > /dev/null

# Raspberry nfs
RASPBERRY_ROOT="$HOME/Files/Raspberry"

mkdir -p "$RASPBERRY_ROOT"
echo "raspberry:/ $RASPBERRY_ROOT nfs users,dev,exec,noauto,rw,suid 0 0" \
    | sudo tee -a /etc/fstab > /dev/null

#####################################################
#
#                   User jobs
#
#####################################################

cp Support/.bash_{profile,envvars} "$HOME"

# Importing .bash_envvars into .bashrc and .bash_profile

echo "

# Setting envvars

if [ -f ~/.bash_envvars ]; then
    . ~/.bash_envvars
fi" >> "$HOME/.bashrc"
