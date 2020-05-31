#!/usr/bin/env sh

# This doesn't work if this script is sourced
. "$(dirname "$0")/../.env"

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
        case "$HOST" in
            'personal'|'work')
                yay -Sy atom
                ;;
        esac
        yay -Sy antibody-bin myrepos zsh
        ;;

    'debian')
        case "$HOST" in
            'personal'|'work')
                sudo apt-get install atom
                ;;
        esac
        sudo apt-get install myrepos zsh
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
