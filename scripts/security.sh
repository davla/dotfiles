#!/usr/bin/env sh

# This script deals with SSH and gpg keys. Namely:
#   - Generates both SSH and gpg keys on demand, prompting the user.
#   - Displays the created public keys.
#   - Changes this git repository's origin remote from HTTPS to SSH.
#   - If an SSH key is created, it can add it as an authorized key for remote
#     hosts, given that the right CLI arguments are provided.
#
# Arguments:
#   - $1: The host to copy SSH public key over to. Optional.
#   - $2+: The users to log in as in the host when copying SSH public key over.
#          The same key is copied for all users. Only required if $1 is given.

#######################################
# Variables
#######################################

# Git origin remote URL
echo "\e[32m[INFO]\e[0m Getting git origin URL"
GIT_ORIGIN="$(git remote get-url origin)"

# SSH base directory
SSH_HOME="$HOME/.ssh"

# Default value for SSH key file name
DEFAULT_SSH_KEY='id_rsa'

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

    # This first makes sure shat ~/.ssh exists, and then adds the SSH key to
    # the authorized ones on the remote host
    printf "\e[32m[INFO]\e[0m Copying SSH key $COPIED_SSH_KEY as "
    echo "$COPIED_USER@$COPIED_HOST"
	ssh "$HOST_STRING" mkdir -p .ssh
	cat "$COPIED_SSH_KEY" | ssh "$HOST_STRING" 'cat >> .ssh/authorized_keys'

    unset COPIED_HOST COPIED_SSH_KEY COPIED_USER HOST_STRING
}

#######################################
# Input processing
#######################################

[ $# -gt 0 ] && {
    HOST="$1"
    # This discards the only CLI argument that is not an user name
    shift
}

#######################################
# Creating SSH keys
#######################################

# Ensuring that ~/.ssh exists
echo "\e[32m[INFO]\e[0m Creating $SSH_HOME"
mkdir -p "$SSH_HOME"

# Prompting the user for SSH key creation
printf 'Do you want to create ssh keys? [y/n] '
read CREATE_SSH_KEYS

case "$(echo "$CREATE_SSH_KEYS" | tr '[:upper:]' '[:lower:]')" in

    # Creating SSH key
    'y'|'yes')
        echo '\e[32m[INFO]\e[0m Creating SSH key'

        # Prompting the user for SSH key filename, handling the default too
        printf "Enter SSH key filename [default '$DEFAULT_SSH_KEY']: "
        read SSH_KEY_FILE_NAME
        [ -z "$SSH_KEY_FILE_NAME" ] && SSH_KEY_FILE_NAME="$DEFAULT_SSH_KEY"

        # Actually creating the SSH key (interactive)
        ssh-keygen -f "$SSH_HOME/$SSH_KEY_FILE_NAME" -t rsa
        ;;

    # Not generating SSH key
    'n'|'no')
        echo "OK. SSH keys won't be created"
        ;;

    # Rejecting any other answer
    *)
        echo >&2 "Invalid answer: $CREATE_SSH_KEYS"
        exit 1
        ;;
esac
unset CREATE_SSH_KEYS SSH_KEY_FILE_NAME

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
    echo '\e[32m[INFO]\e[0m Changing this repository remote to use SSH'

    # Changing this repository URL to use SSH
    echo "$GIT_ORIGIN" | \
        sed -E -e 's|https://(.+?)/(.+?)/(.+?)(.git)?|git@\1:\2/\3.git|' \
            -e 's/(\.git)+$/.git/g' \
        | xargs git remote set-url origin
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
echo '\e[32m[INFO]\e[0m Copying SSH keys to hosts'
if [ -n "$HOST" ]; then
    for SSH_USER in "$@"; do
        copy_key "$SSH_USER" "$HOST" "$SSH_HOME/id_rsa.pub"
    done
else
    exit 0
fi
