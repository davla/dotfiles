#!/usr/bin/env sh

# This script changes a UNIX user login name and its home directory. It also
# changes its and root's password.
#
# Due to how UNIX works, this script needs to be executed as any user other
# than the one whose login name is changed. IF this is not the case, the script
# will exit with an error.
#
# Arguments:
#   - $1: the new user name. Defaults to 'pi'.
#   - $2: the old user name. If not specified, an non-root user with an active
#         password is used, provided that there's only one.

# This doesn't work if this script is sourced
. "$(dirname "$0")/lib.sh"

#######################################
# Input processing
#######################################

NEW_USER="${1:-pi}"

# If the current user is not given as a CLI parameter, getting the only one
# that can login and is not root
CURRENT_USER="${2:-$(sudo getent shadow \
    | grep --invert-match --perl-regexp '.*:[!\*]' \
    | grep --invert-match '^root' | cut --delimiter ':' --fields 1)}"

[ "$(echo "$CURRENT_USER" | wc --lines)" -ne 1 ] && {
    echo 2>&1 'There is not only one non-root users with an active password:'
    echo 2>&1 "$CURRENT_USER"
    exit 1
}

#######################################
# Prepare for login name change
#######################################

# UNIX doesn't allow to change the current logged-in user login name.
[ "$(id --user --name)" = "$CURRENT_USER" ] && {
    printf 2>&1 'This script needs to be run with an user other than %s\n' \
        "$CURRENT_USER"
    exit 1
}

# The old user needs to have no running processes.
#
# Masking the exit code of the subshell is necessary, as ps exits with an error
# if no processes matching the criteria are found.
print_info "Kill $CURRENT_USER processes"
CURRENT_USER_PROCESSES="$(ps --no-header --User "$CURRENT_USER" -o pid)" \
    || true
# shellcheck disable=SC2086
[ -n "$CURRENT_USER_PROCESSES" ] && sudo kill $CURRENT_USER_PROCESSES

#######################################
# Change login name and home
#######################################

print_info "Change login name $CURRENT_USER -> $NEW_USER"
sudo usermod --login "$NEW_USER" "$CURRENT_USER"
sudo usermod --home "/home/$NEW_USER" --move-home "$NEW_USER"
sudo groupmod --new-name "$NEW_USER" "$CURRENT_USER"

#######################################
# Change passwords
#######################################

print_info "Change $NEW_USER password"
sudo passwd "$NEW_USER"

print_info 'Change root password'
sudo passwd
