#!/usr/bin/env bash

# This script installs asdf and plugins

#######################################
# Dependencies
#######################################

apt-get install libreadline-dev libncurses-dev libssl-dev libffi-dev

#######################################
# Installing and sourcing asdf
#######################################

git clone 'https://github.com/asdf-vm/asdf.git' "$ASDF_PATH"
git -C "$ASDF_PATH" describe --abbrev=0 --tags \
    | xargs git -C "$ASDF_PATH" checkout 2> /dev/null
mkdir -p "$ASDF_DATA_DIR"
mkdir -p "$ASDF_CONFIG_DIR"
source "$ASDF_PATH/asdf.sh"

#######################################
# Installing plugins
#######################################

echo lua nodejs python ruby | xargs -n 1 asdf plugin-add
# nodejs dev team gpg keys
bash "$ASDF_DATA_DIR/plugins/nodejs/bin/import-release-team-keyring"
