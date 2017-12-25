#!/usr/bin/env bash

# This script sets content and color of
# terminal prompt for both user and root

#####################################################
#
#                   Variables
#
#####################################################

# Green
ROOT_PS1='\\[\\033[38;5;40m\\]\\u@\\h:*\/\\W\\$ '

# Orange
USER_PS1='\\[\\033[38;5;202m\\]\\u@\\h:*\/\\W\\$ '

#####################################################
#
#                   Functions
#
#####################################################

function set-ps1 {
    local USER_HOME="$1"
    local PS1="$2"

    sudo sed -r -i "s/#?(.*)PS1=.+/\1PS1='$PS1'/g" "$USER_HOME/.bashrc"
    echo "PS1='${PS1//\\\\/\\}'" | sudo tee -a "$USER_HOME/.bash_profile" \
        > /dev/null
}

#####################################################
#
#                       Root
#
#####################################################

set-ps1 '/root' "$ROOT_PS1"

#####################################################
#
#                       User
#
#####################################################

set-ps1 "$HOME" "$USER_PS1"
