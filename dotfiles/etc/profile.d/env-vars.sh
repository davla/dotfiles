#!/usr/bin/env sh

# {{@@ header() @@}}
#
# This file contains system environment variables, that is those not specific
# to any user

#######################################
# asdf
#######################################

export ASDF_HOME='{{@@ asdf_home @@}}'
export ASDF_CONFIG='{{@@ asdf_config @@}}'
export ASDF_CONFIG_FILE="$ASDF_CONFIG/.asdfrc"
export ASDF_DATA_DIR="$ASDF_HOME/data"
export ASDF_DEFAULT_TOOL_VERSIONS_FILENAME="$ASDF_CONFIG/.tool-versions"

#######################################
# dotdrop
#######################################

export DOTFILES_HOME="{{@@ dotfiles_home | find_in_home @@}}"
