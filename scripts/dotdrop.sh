#!/usr/bin/env sh

# This script installs dotdrop dependencies in a virtual environment

. ./.env

#######################################
# Input processing
#######################################

DOTDROP_DIR="$1"

#######################################
# Creating dotdrop virtualenv
#######################################

sudo apt-get install python3 pipenv

cd "$DOTDROP_DIR" || exit
pipenv install
cd - > /dev/null 2>&1 || exit
