#!/usr/bin/env sh

# This script installs dotdrop dependencies in a virtual environment

# This doesn't work if this script is sourced
. "$(dirname "$0")/lib.sh"

#######################################
# Input processing
#######################################

DOTDROP_DIR="$1"

#######################################
# Create dotdrop virtualenv
#######################################

print_info 'Install pipenv'
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
print_info 'Install project dependencies'
pipenv install
cd - > /dev/null 2>&1 || exit
