#!/usr/bin/env bash

# This script sets up the environment for new shells

#####################################################
#
#                   System-wide
#
#####################################################

# Shimming `su` to execute `su -` when called with no arguments
grep 'function su' /etc/bash.bashrc &> /dev/null \
    || tail -n +2 Support/shell/su.sh \
        | sudo tee -a /etc/bash.bashrc &> /dev/null

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
