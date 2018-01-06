#!/usr/bin/env bash

# This script sets anacron daily jobs, both root and user ones.
# It also fixes an error for which anacron is disabled by
# symlinking it to /bin/true from live install settings.
# Finally, it enables anacron to run on battery power

# Argumnts:
#   - $1: The user non-root commands should be executed as.

#####################################################
#
#                   Privileges
#
#####################################################

# Checking for root privileges: if don't
# have them, recalling this script with sudo
if [[ $EUID -ne 0 ]]; then
    echo 'This script needs to be run as root'
    sudo bash $0 $@
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
if [[ "$ANACRON_EXEC" -ef /bin/true ]]; then
    REAL_ANACRON=$(find $(dirname "$ANACRON_EXEC") -name "anacron*" \
        -not -name 'anacron' -executable | head -n 2 | tail -n 1)
    ln -fs "$REAL_ANACRON" "$ANACRON_EXEC"
fi

#####################################################
#
#               Anacron configuration
#
#####################################################

sed -i 's/ANACRON_RUN_ON_BATTERY_POWER=no/ANACRON_RUN_ON_BATTERY_POWER=yes/g' \
    /etc/default/anacron

#####################################################
#
#                   Root tasks
#
#####################################################

ROOT_DAILY=(
    'update-notifier'
    'install-postman'
)
for BIN in ${ROOT_DAILY[@]}; do
    ln -fs $(which "$BIN") "/etc/cron.daily/$BIN"
done

#####################################################
#
#                   User tasks
#
#####################################################

echo -n "

1        1        git.updates	su $USER_NAME -c 'pull-repos'
1        3        node.updates	su $USER_NAME -c 'node-updater'
1        5        npm.updates	su $USER_NAME -c 'npm-updater'
" >> /etc/anacrontab
