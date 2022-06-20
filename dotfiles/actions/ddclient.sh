#!/usr/bin/env sh

# This script interactively adds the password to the ddclient configuration
# file by prompting the user to type it in.
#
# Arguments:
#   - $1: The ddclient configuration file path

# This doesn't work if this script is sourced
. "$(dirname "$0")/../../scripts/lib.sh"

#######################################
# Input processing
#######################################

DDCLIENT_FILE="$1"

#######################################
# Prompt for password
#######################################

printf 'Insert DNS service password: '

OLD_STTY="$(stty -g)"
stty -echo
read DNS_PASSWD
stty "$OLD_STTY"

#######################################
# Add password to config file
#######################################

print_info 'Update ddclient password'
sed -i "7ipassword=$DNS_PASSWD" "$DDCLIENT_FILE"
