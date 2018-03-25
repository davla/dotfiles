#!/usr/bin/env bash

# This script sets up the environment for new shells,
# both root and user

#####################################################
#
#                       Root
#
#####################################################

# Setting root PATH to contain binaries in /usr/local/
sudo bash -c 'echo '\''
export PATH="/usr/local/sbin:/usr/local/bin:$PATH"'\'' >> $HOME/.bashrc'

#####################################################
#
#                       User
#
#####################################################

# Setting custom environment variables for the user
cp Support/.bash_envvars "$HOME"
echo '
# Setting envvars

if [ -f ~/.bash_envvars ]; then
    . ~/.bash_envvars
fi' >> "$HOME/.bashrc"
