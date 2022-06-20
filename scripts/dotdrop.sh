#!/usr/bin/env sh

# This script installs dotdrop dependencies in a virtual environment

#######################################
# Input processing
#######################################

DOTDROP_DIR="$1"

#######################################
# Creating dotdrop virtualenv
#######################################

case "$DISTRO" in
    'arch')
        yay -S --needed python python-pipenv
        ;;

    'debian')
        sudo apt-get update
        sudo apt-get install python3 pipenv
        ;;
esac

cd "$DOTDROP_DIR" || exit
pipenv install
cd - > /dev/null 2>&1 || exit
