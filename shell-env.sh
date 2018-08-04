#!/usr/bin/env bash

# This script sets up the environment for new shells, both root and user

#####################################################
#
#                   Functions
#
#####################################################

# This function adds sourcing of file /etc/profile to the passed file
#
# Arguments:
#   - $1: The file the sourcing of /etc/profile will be added to
function add-profile {
    local FILE="$1"

    if ! sudo grep '\. /etc/profile' "$FILE" &> /dev/null; then
        sudo sed -i '3i# Among other, setting PATH also for non-login shells' \
            "$FILE"
        sudo sed -i '4i. /etc/profile' "$FILE"
    fi
}

#####################################################
#
#                       Root
#
#####################################################

# Setting root PATH to the one in /etc/profile so as to overwrite it when
# using su
add-profile /root/.bashrc

#####################################################
#
#                       User
#
#####################################################

# Sourcing /etc/profile for non-login shell, just in case
add-profile "$HOME/.bashrc"

# Setting custom environment variables for the user
cp Support/.bash_envvars "$HOME"

grep '\.bash_envvars' "$HOME/.bashrc" &> /dev/null || echo '
# Setting envvars

if [ -f ~/.bash_envvars ]; then
    . ~/.bash_envvars
fi' >> "$HOME/.bashrc"
