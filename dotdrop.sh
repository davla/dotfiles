#!/usr/bin/env sh

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
