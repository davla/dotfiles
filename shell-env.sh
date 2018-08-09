#!/usr/bin/env bash

# This script sets up the environment for new shells, both root and user

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
