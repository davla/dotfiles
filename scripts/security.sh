#!/usr/bin/env sh

# This script deals with some security setup. Namely:
#   - Generates SSH keys if not already present.
#   - Changes this git repository's origin remote from HTTPS to SSH. It does
#       also display the public SSH key so that it can be copied into GitHub.
#   - Creates gpg keys if not already present
#   - Copies SSH keys over to remote hosts if CLI arguments are passed.
#
# Arguments:
#   - $1: The host to copy SSH public key over to. Optional.
#   - $2+: The users to log in as in the host when copying SSH public key over.
#          The same key is copied for all users. Only required if $1 is given.

#######################################
# Variables
#######################################

# Path to this scrpt parent directory. Doesn't work if this script is sourced
PARENT_DIR="$(dirname "$0")"

# Git origin remote URL
GIT_ORIGIN="$(git -C "$PARENT_DIR" remote get-url origin)"

# SSH base directory
SSH_HOME="$HOME/.ssh"

#######################################
# Functions
#######################################

# This function copies the given public key over to a SSH host. Il logs in as
# the provided user via password.
#
# Arguments:
#   - $1: The user to log in the remote host as.
#   - $2: The remote host to copy the SSH key over to.
#   - $3: The SSH key to be copied over.
copy_key() {
	COPIED_USER="$1"
	COPIED_HOST="$2"
    COPIED_SSH_KEY="$3"

    HOST_STRING="$COPIED_USER@$COPIED_HOST"

	ssh "$HOST_STRING" mkdir -p .ssh
	cat "$COPIED_SSH_KEY" | ssh "$HOST_STRING" 'cat >> .ssh/authorized_keys'

    unset COPIED_HOST COPIED_SSH_KEY COPIED_USER HOST_STRING
}

#######################################
# Input processing
#######################################

[ $# -gt 0 ] && {
    HOST="$1"
    shift
}

#######################################
# Creating SSH keys
#######################################

mkdir -p "$SSH_HOME"
[ ! -f "$SSH_HOME/id_rsa" ] \
    && ssh-keygen -f "$SSH_HOME/id_rsa" -t rsa

#######################################
# Changing git origin of this repo
#######################################

# If remote origin is https, it's not ssh
echo "$GIT_ORIGIN" | grep 'https' > /dev/null 2>&1 && {
    echo 'Copy the SSH key into GitHub.'
    cat "$SSH_HOME/id_rsa.pub"
    # shellcheck disable=2034
    read ANSWER
    unset ANSWER

    # Changing this repository URL to use SSH
    echo "$GIT_ORIGIN" | \
        sed -E -e 's|https://(.+?)/(.+?)/(.+?)(.git)?|git@\1:\2/\3.git|' \
            -e 's/(\.git)+$/.git/g' \
        | xargs git -C "$PARENT_DIR" remote set-url origin
}

#######################################
# Creating gpg keys
#######################################

[ -z "$(gpg --list-secret-keys)" ] && {
    echo 'Generating gpg key'

    printf 'Enter the gpg key name: '
    read GPG_NAME

    printf 'Enter the gpg email: '
    read GPG_EMAIL

    echo 'Generating gpg keys with these parameters:'
    GPG_ARGS="$(mktemp)"
    tee "$GPG_ARGS" <<EOF
Key-Type: 1
Key-Length: 4096
Expire-Date: 0
Name-Real: $GPG_NAME
Name-Email: $GPG_EMAIL
EOF
    gpg --batch --generate-key "$GPG_ARGS"
    rm "$GPG_ARGS"

    echo 'Copy the GPG key into GitHub.'
    # Actually getting the content to paste on GitHub
    gpg --list-secret-keys --with-colons | grep 'sec' | cut -d ':' -f 5 \
        | xargs gpg --armor --export
    # shellcheck disable=2034
    read ANSWER
    unset ANSWER
}

#######################################
# Copying ssh keys to remote host
#######################################

# Need an if here to exit with no error in case no CLI parameters are passed.
if [ -n "$HOST" ]; then
    for SSH_USER in "$@"; do
        copy_key "$SSH_USER" "$HOST" "$SSH_HOME/id_rsa.pub"
    done
else
    exit 0
fi
