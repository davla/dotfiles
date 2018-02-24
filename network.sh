#!/usr/bin/env bash

# This script deals with networking tasks. In particular:
#   - It populates /etc/hosts file with most frequently
#       visited remote websites and adds some local
#       resources.
#   - It installs a script to disable Wi-Fi when cabled
#       connections are active

# Arguments:
#	- $1: If 'refresh', only refreshes remote websites

#####################################################
#
#                   Variables
#
#####################################################

REMOTE_RESOURCES=(
    'duckduckgo.com'
    'forum.pokemoncentral.it'
    'google.com'
    'it.insegreto.com'
    'nonsolomamma.com'
    'pokemon.gamespress.com'
    'serebii.net'
    'wiki.pokemoncentral.it'
)
REMOTE_RESOURCES_MARKER='WWW'

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

[[ "$1" == 'refresh' ]] && REFRESH='true' || REFRESH='false'

#####################################################
#
#               Non-refreshing tasks
#
#####################################################

if [[ "$REFRESH" == 'false' ]]; then

#####################################################
#
#               Local resources
#
#####################################################

	# Adding local resources and a marker for frequently
    # accessed remote websites
	echo -n "
192.168.1.3     memorione
192.168.0.11        raspberry
192.168.0.1		router

# $REMOTE_RESOURCES_MARKER
" >> /etc/hosts

#####################################################
#
#           Wi-Fi management script
#
#####################################################

    DISPATCHERS_PATH='/etc/NetworkManager/dispatcher.d'
    DISPATCHER_SCRIPT='99-no-wireless-on-wired'
    DISPATCHER_SCRIPT_PATH="$DISPATCHERS_PATH/$DISPATCHER_SCRIPT"

    # Copying the NetworkManager dispatch script to
    # the right location
    cp "Support/network/$DISPATCHER_SCRIPT" "$DISPATCHERS_PATH"

    # Setting the right permissions and ownership
    chown 'root:root' "$DISPATCHER_SCRIPT_PATH"
    chmod u+w,ga-w,u-s,+x "$DISPATCHER_SCRIPT_PATH"

fi

#####################################################
#
#               Remote websites
#
#####################################################

# Line numberof the remote resources marker
REMOTE_LINE=$(grep -n "$REMOTE_RESOURCES_MARKER" /etc/hosts | \
    awk -F : '{ print $1 }')

# Clearing remote resources entries
REMOTE_LINE=$(( REMOTE_LINE + 2 ))
sed -i "$REMOTE_LINE,\$d" /etc/hosts

# Adding an entry for every remote resource
for WEBSITE in "${REMOTE_RESOURCES[@]}"; do
	IPS=$(host "$WEBSITE")

    grep 'has address' <<<"$IPS" | tail -n 1 | \
        awk '{print($1, "\t", $4)}' >> /etc/hosts
    grep 'has IPv6 address' <<<"$IPS" | tail -n 1 | \
        awk '{print($1, "\t", $5)}' >> /etc/hosts
done
