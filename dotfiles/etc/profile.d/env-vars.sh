#!/usr/bin/env sh

# {{@@ header() @@}}

# This file contains system environment variables, that is those not specific
# to any user

#######################################
# asdf
#######################################

export ASDF_PATH='/opt/asdf-vm'
export ASDF_CONFIG_PATH="$ASDF_PATH/etc"
export ASDF_CONFIG_FILE="$ASDF_CONFIG_PATH/.asdfrc"
export ASDF_DATA_DIR="$ASDF_PATH/data"
export ASDF_DEFAULT_TOOL_VERSIONS_FILENAME="$ASDF_CONFIG_PATH/.tool-versions"

#######################################
# dotdrop
#######################################

export DOTFILES_HOME="{{@@ dotfiles_home | find_in_home @@}}"
