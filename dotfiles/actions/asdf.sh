#!/usr/bin/env bash

# This script installs asdf

#######################################
# Dependencies
#######################################

apt-get install libreadline-dev libncurses-dev libssl-dev libffi-dev

#######################################
# Installing asdf
#######################################

git clone 'https://github.com/asdf-vm/asdf.git' "$ASDF_PATH"
git -C "$ASDF_PATH" describe --abbrev=0 --tags \
    | xargs git -C "$ASDF_PATH" checkout 2> /dev/null
mkdir -p "$ASDF_DATA_DIR"
mkdir -p "$ASDF_CONFIG_PATH"
