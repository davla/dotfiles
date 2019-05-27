#!/usr/bin/env bash

# This script installs language versions via asdf

#######################################
# Functions
#######################################

# This function installs the latest version of a language and sets it as
# default
#
# Arguments:
#   - $1: The asdf plugin whose latest version will be installed.
install_latest() {
    PLUGIN="$1"

    # The two greps filter out dev and non "number only" versions.
    LATEST_VERSION="$(asdf list-all "$PLUGIN" | grep -v dev \
        | grep -Px '[\d\.]*' | sort -Vr | head -n 1)"

    asdf install "$PLUGIN" "$LATEST_VERSION"
    asdf global "$PLUGIN" "$LATEST_VERSION"

    unset LATEST_VERSION PLUGIN
}

#######################################
# lua
#######################################

asdf install lua 5.1
install_latest lua

#######################################
# node.js
#######################################

# linking .default-npm-packages where the plugin expects it to be
ln -sf "$ASDF_CONFIG_PATH/.default-npm-packages" "$HOME/.default-npm-packages"
install_latest nodejs

#######################################
# python
#######################################

PYTHON_2_7="$(asdf list-all python | grep -P '^2\.7*' | grep -v dev \
    | sort -Vr | head -n 1)"
PYTHON_3="$(asdf list-all python | grep -P '^3\.*' | grep -v dev | sort -Vr \
    | head -n 1)"
asdf install python "$PYTHON_2_7"
asdf install python "$PYTHON_3"
asdf global python "$PYTHON_3" "$PYTHON_2_7"

#######################################
# ruby
#######################################

# linking .default-gems where the plugin expects it to be
ln -sf "$ASDF_CONFIG_PATH/.default-gems" "$HOME/.default-gems"
install_latest ruby
