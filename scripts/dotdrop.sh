#!/usr/bin/env sh

# This script installs dotdrop dependencies

. ./.env

#######################################
# Input processing
#######################################

DOTDROP_DIR="$1"

#######################################
# Script
#######################################

sudo apt-get install python3 pipenv

cd "$DOTDROP_DIR" || exit
pipenv install
cd - > /dev/null || exit
