#!/usr/bin/env sh

# This script sets up non-root anacron environment.
#
# Arguments:
#   - $1: Anacron spool directory
#   - $2: User crontab file

#######################################
# Input processing
#######################################

ANACRON_SPOOL="$1"
CRONTAB_FILE="$2"

#######################################
# Initializing anacron
#######################################

mkdir -p "$ANACRON_SPOOL"

#######################################
# Setting up crontab
#######################################

crontab "$CRONTAB_FILE"
rm -f "$CRONTAB_FILE"
