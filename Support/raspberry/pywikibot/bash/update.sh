#!/usr/bin/env bash

# This script updates the pywikibot installation

shopt -s expand_aliases

source "$HOME/.bash_envvars"

#####################################################
#
#                   Aliases
#
#####################################################

# Echoes normally if from terminal emulator, otherwise uses syslog
tty -s && alias print='echo' \
    || alias print='logger -p local0.info -t PYWIKIBOT'

#####################################################
#
#                   Updating
#
#####################################################

cd "$PYWIKIBOT_DIR" || exit 1

# The usual line for nothing to pull is 'Already up to date.'
[[ $(git pull --all | wc -l) -gt 2 ]] && print 'Updated' \
    || print 'Not updated'

# Nothing is printed when submodules are not updated
[[ -n $(git submodule update) ]] && print 'Submodules updated' \
    || print 'Submodules not updated'
