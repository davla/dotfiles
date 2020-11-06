#!/usr/bin/env sh

# This script interactively adds the password to the ddclient configuration
# file by prompting the user to type it in.
#
# Arguments:
#   - $1: The ddclient configuration file path

#######################################
# Input processing
#######################################

DDCLIENT_FILE="$1"

#######################################
# Prompting for password
#######################################

printf 'Insert DNS service password: '

OLD_STTY="$(stty -g)"
stty -echo
read DNS_PASSWD
stty "$OLD_STTY"

#######################################
# Adding password to config file
#######################################

sed -i "7ipassword=$DNS_PASSWD" "$DDCLIENT_FILE"
