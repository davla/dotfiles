#!/usr/bin/env sh

# {{@@ header() @@}}
#
# This file contains system-wide, non user-specific environment variables

#######################################
# dotdrop
#######################################

export DOTFILES_HOME="{{@@ dotfiles_home | find_in_home @@}}"
