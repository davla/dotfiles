#!/usr/bin/env bash

# This script populates /etc/hosts file with most frequently
# visited remote websites and adds some local resources.

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
#               Local resources
#
#####################################################

if [[ "$REFRESH" == 'false' ]]; then

	# Adding local resources and a marker for frequently
    # accessed remote websites
	echo "
192.168.1.3     memorione
192.168.0.11        raspberry
192.168.0.1		router

# $REMOTE_RESOURCES_MARKER
" >> /etc/hosts
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
REMOTE_LINE=$(( $REMOTE_LINE + 2 ))
sed -i "$REMOTE_LINE,\$d" /etc/hosts

# Adding an entry for every remote resource
for WEBSITE in "${REMOTE_RESOURCES[@]}"; do
	IPS=$(host "$WEBSITE")

    grep 'has address' <<<"$IPS" | tail -n 1 | \
        awk '{print($1, "\t", $4)}' >> /etc/hosts
    grep 'has IPv6 address' <<<"$IPS" | tail -n 1 | \
        awk '{print($1, "\t", $5)}' >> /etc/hosts
done
