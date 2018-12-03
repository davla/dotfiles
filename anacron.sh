#!/usr/bin/env bash

# This script sets anacron daily jobs, both root and user ones. It also fixes
# an error for which anacron is disabled by symlinking it to /bin/true from
# live install settings. Then it sets up a custom logger configuration and log
# rotation. Finally, it enables anacron to run on battery power.

# Argumnts:
#   - $1: The user non-root commands should be executed as.

#####################################################
#
#                   Variables
#
#####################################################

# Absolute path of this script's parent directory
PARENT_DIR="$(dirname "${BASH_SOURCE[0]}")"
LIB_DIR="$PARENT_DIR/lib"

# Use to check whether custom job have already been added to anacron
CUSTOM_JOBS_MARKER='# Custom jobs'

# Commands to be run daily as root
ROOT_DAILY=(
    'install-postman'
    'node-updater'
    'npm-updater'
    'update-notifier'
)

#####################################################
#
#                   Privileges
#
#####################################################

# Checking for root privileges: if don't have them, recalling this script with
# sudo
if [[ $EUID -ne 0 ]]; then
    echo 'This script needs to be run as root'
    sudo bash "$0" "$@"
    exit 0
fi

#####################################################
#
#               Input processing
#
#####################################################

USER_NAME="$1"

#####################################################
#
#                   Bug fixes
#
#####################################################

ANACRON_EXEC="$(which anacron)"

# If anacron executable is a link to /bin/true, the real executable is found
# and then the anacron executable is likned to that
[[ "$ANACRON_EXEC" -ef /bin/true ]] \
    && dirname "$ANACRON_EXEC" \
        | xargs -i find '{}' -name "anacron*" -not -name 'anacron' -executable \
        | head -n 2 \
        | tail -n 1 \
        | xargs -i ln -sf '{}' "$ANACRON_EXEC"

#####################################################
#
#               Anacron configuration
#
#####################################################

sed -i 's/ANACRON_RUN_ON_BATTERY_POWER=no/ANACRON_RUN_ON_BATTERY_POWER=yes/g' \
    /etc/default/anacron

#####################################################
#
#               Custom logger
#
#####################################################

cp "$LIB_DIR/logger/logrotate-custom.conf" /etc/logrotate.d
cp "$LIB_DIR/logger/rsyslog-custom.conf" /etc/rsyslog.d

#####################################################
#
#                   Root tasks
#
#####################################################

# Linking root daily commands into /etc/cron.daily, so that they are executed
# by anacron.
for CMD in "${ROOT_DAILY[@]}"; do
    EXEC="$(which "$CMD")"

    # Not linking if the command executable file is not found
    if [[ $? -ne 0 ]]; then
        echo >&2 "$CMD executable not found: have you linked it?"
        continue
    fi

    ln -fs "$EXEC" "/etc/cron.daily/$CMD"
done

#####################################################
#
#                   User tasks
#
#####################################################

# No need to add custom jobs if they are already there
grep "$CUSTOM_JOBS_MARKER" /etc/anacrontab &> /dev/null && exit 0

# Custom jobs cannot be added without a user name
if [[ -z "$USER_NAME" ]]; then
    echo >&2 'User name not provided - cannot add user jobs'
    exit 1
fi

# Adding custom jobs
echo -n "
$CUSTOM_JOBS_MARKER

@daily      1        git.updates	runuser -u $USER_NAME pull-repos
" >> /etc/anacrontab
