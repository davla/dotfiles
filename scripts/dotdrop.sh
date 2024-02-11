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
        sudo pacman -S --needed gcc python python-pipenv
        ;;

    'debian')
        sudo apt-get update
        sudo apt-get install gcc python3 pipenv
        ;;
esac

cd "$DOTDROP_DIR" || exit

print_info 'Clear existing virtual environment'
sudo rm -rf .venv

print_info 'Install project dependencies'
if which asdf > /dev/null; then
    asdf which python | xargs pipenv install --dev --python
else
    pipenv install --dev
fi

cd - > /dev/null 2>&1 || exit
