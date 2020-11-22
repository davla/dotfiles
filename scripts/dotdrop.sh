#!/usr/bin/env sh

# This script installs dotdrop dependencies in a virtual environment

# This doesn't work if this script is sourced
. "$(dirname "$0")/../.env"

#######################################
# Input processing
#######################################

DOTDROP_DIR="$1"

#######################################
# Creating dotdrop virtualenv
#######################################

case "$DISTRO" in
    'arch')
        yay -Syy
        yay -S python python-pipenv
        ;;

    'debian')
        sudo apt-get update
        sudo apt-get install python3 pipenv
        ;;
esac

cd "$DOTDROP_DIR" || exit
pipenv install
cd - > /dev/null 2>&1 || exit
