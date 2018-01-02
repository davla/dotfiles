#!/usr/bin/env bash

# This scripts sets up SSH key access to raspberry,
# creating the keys if necessary


#####################################################
#
#                   Variables
#
#####################################################

SSH_HOME="$HOME/.ssh"

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

[[ ! -d "$SSH_HOME" ]] && mkdir "$SSH_HOME"
[[ ! -e "$SSH_HOME/id_rsa" ]] && ssh-keygen -t rsa

#####################################################
#
#           SSH keys access setup
#
#####################################################

copy-key 'pi' 'raspberry'
copy-key 'root' 'raspberry'
