#!/usr/bin/env sh

. ../.env

# This script sets up anacron environment. It installs programs used in
# anacrontabs and sets up the spool directory and a custom crontab if passed.
#
# Arguments:
#   - $1: Anacron spool directory. Optional.
#   - $2: User crontab file. Optional.

#######################################
# Input processing
#######################################

ANACRON_SPOOL="$1"
CRONTAB_FILE="$2"

#######################################
# Installing dependencies
#######################################

case "$DISTRO" in
    'arch')
        yay -S antibody-bin atom myrepos zsh
        ;;

    'debian')
        sudo apt-get install atom myrepos zsh
        sudo mr -d /opt/antibody install
        ;;
esac

#######################################
# Initializing anacron
#######################################

[ -n "$ANACRON_SPOOL" ] && mkdir -p "$ANACRON_SPOOL"

#######################################
# Setting up crontab
#######################################

if [ -n "$CRONTAB_FILE" ]; then
    crontab "$CRONTAB_FILE"
    rm -f "$CRONTAB_FILE"
fi
