#!/usr/bin/env bash

# This script sets anacron daily jobs, both root and user ones.
# It also fixes an error for which anacron is disabled by
# symlinking it to /bin/true from live install settings.
# Then it sets up a custom logger configuration and log rotation.
# Finally, it enables anacron to run on battery power.

# Argumnts:
#   - $1: The user non-root commands should be executed as.

#####################################################
#
#                   Variables
#
#####################################################

CUSTOM_JOBS_MARKER='# Custom jobs'
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

# Checking for root privileges: if don't
# have them, recalling this script with sudo
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

ANACRON_EXEC=$(which anacron)

# anacron executable is a link to /bin/true
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

cp Support/logger/logrotate-custom.conf /etc/logrotate.d
cp Support/logger/rsyslog-custom.conf /etc/rsyslog.d

#####################################################
#
#                   Root tasks
#
#####################################################

for BIN in "${ROOT_DAILY[@]}"; do
    EXEC_BIN=$(which "$BIN")

    if [[ $? -ne 0 ]]; then
        echo >&2 "$BIN executable not found: have you linked it?"
        continue
    fi

    ln -fs "$EXEC_BIN" "/etc/cron.daily/$BIN"
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

1        1        git.updates	su $USER_NAME -c 'pull-repos'
" >> /etc/anacrontab
