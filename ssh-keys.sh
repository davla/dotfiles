#!/usr/bin/env bash

# This scripts generates SSH keys if necessary, and optionally copies them over
# to a passed remote host for SSH access

#####################################################
#
#                   Variables
#
#####################################################

SSH_HOME="$HOME/.ssh"

#####################################################
#
#                   Parameters
#
#####################################################

# Remote host to copy the keys over for SSH access, can be empty
HOST="$2"

#####################################################
#
#                   Functions
#
#####################################################

# ATTENTION! Interactive!
# Copiesthe the public key over to the passed SSH host, as
# the provided user. Will prompt for password to log in.
function copy-key {
	local USER="$1"
	local HOST="$2"

	ssh "$USER@$HOST" mkdir -p .ssh
	cat "$SSH_HOME/id_rsa.pub" | ssh "$USER@$HOST" 'cat >> .ssh/authorized_keys'
}

#####################################################
#
#               Keys creation
#
#####################################################

mkdir -p "$SSH_HOME"
[[ ! -f "$SSH_HOME/id_rsa" ]] && ssh-keygen -t rsa

#####################################################
#
#           SSH keys access setup
#
#####################################################

# If a host is passed, copying keys over for SSH access
if [[ -n "$HOST" ]]; then
    copy-key 'pi' "$HOST"
    copy-key 'root' "$HOST"
fi
