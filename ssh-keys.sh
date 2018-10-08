#!/usr/bin/env bash

# This scripts deals with common SHH keys setup. Namely:
#   - Generates SSH keys if not already present.
#   - If a remote host is passed, copies them over for SSH access.
#   - Displays the public key to be copied to git hosting services and changes
#       this very repository's remote from HTTPS to SSH.

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
HOST="$1"

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
#                   Keys creation
#
#####################################################

mkdir -p "$SSH_HOME"
[[ ! -f "$SSH_HOME/id_rsa" ]] && ssh-keygen -t rsa

#####################################################
#
#               SSH keys access setup
#
#####################################################

# If a host is passed, copying keys over for SSH access
if [[ -n "$HOST" ]]; then
    copy-key 'pi' "$HOST"
    copy-key 'root' "$HOST"
fi

#####################################################
#
#               Git remotes management
#
#####################################################

# By passing this directory to the next git commands, this script can be
# called from anywhere
PARENT_DIR="$(dirname "$0")"

GIT_ORIGIN="$(git -C "$PARENT_DIR" remote get-url origin)"

if grep 'https' <<<"$GIT_ORIGIN" &> /dev/null; then
    echo 'Copy the key to your git hosting service'
    cat "$SSH_HOME/id_rsa.pub"
    read

    # Changing this repository URL to use SSH
    sed -E 's|https://(.+?)/(.+?)/(.+?).git|git@\1:\2/\3.git|' \
            <<<"$GIT_ORIGIN" \
        | xargs git -C "$PARENT_DIR" remote set-url origin
fi
