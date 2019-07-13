#!/usr/bin/env sh

# This script sets up the system startup, including both system and user
# startup jobs

. ./.env

#######################################
# Variables
#######################################

# Desktop files shell globs of user startup jobs which need to be delayed
USER_DELAYED='*npass*.desktop'

#######################################
# Setting up system/user startup jobs
#######################################

dotdrop -U both install -p startup

#######################################
# Further setup
#######################################

# Delaying some user autostart jobs

# Need the loop since every DELAYED item needs to be passed to find, as it can
# match multiple files
echo "$USER_DELAYED" | while read JOB; do
    # Prefixing the Exec command with sleep. The first sed pattern makes the
    # script idempotent, as it doesn't add sleep when it's already there.
    find "$HOME/.config/autostart" -name "$JOB" -exec sed -i -E \
        "/Exec=.*sleep/! s/Exec=(.+)/Exec=sh -c 'sleep 2s \&\& \1'/g" '{}' \;
done
