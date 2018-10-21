#!/usr/bin/env bash

# This script sets up the environment for new shells

#####################################################
#
#                   System-wide
#
#####################################################

# Setting PATH at every user switch, regardless of whether the shell is login
if ! sudo grep -P 'ALWAYS_SET_PATH\s+yes' /etc/login.defs &> /dev/null; then
    LINE_NO=$(sudo grep -n '^ENV_PATH' /etc/login.defs | cut -d ':' -f 1)
    LINE_NO=$(( LINE_NO + 1 ))

    sudo sed -i -e "$(( LINE_NO - 1 ))G" \
                -e "${LINE_NO}i#" \
                -e "${LINE_NO}i# Sets the PATH to one of the above values \
also for non-login shells" \
                -e "${LINE_NO}i#" \
                -e "${LINE_NO}iALWAYS_SET_PATH         yes" /etc/login.defs
fi

#####################################################
#
#                       User
#
#####################################################

# Setting custom environment variables for the user
cp Support/shell/.bash_envvars "$HOME"
grep '\.bash_envvars' "$HOME/.bashrc" &> /dev/null || echo '
# Setting envvars
if [ -f ~/.bash_envvars ]; then
    . ~/.bash_envvars
fi' >> "$HOME/.bashrc"
