#!/usr/bin/env bash

# This script initializes bash login shells.
# Most of the setup is delegated to bashrc

# {{@@ header() @@}}

#######################################
# Loading configuration paths
#######################################

# shellcheck disable=2027,2140
source "{{@@ dotdirs_file | replace("~", "$HOME") @@}}"

#######################################
# Delegating to bashrc
#######################################

source "$BDOTDIR/.bashrc"
