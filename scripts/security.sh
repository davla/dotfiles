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

# This doesn't work if this script is sourced
. "$(dirname "$0")/../.env"

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
        SSH_KEY_PATH="$SSH_HOME/$SSH_KEY_FILE_NAME"
        ssh-keygen -f "$SSH_KEY_PATH" -t rsa

        # Displaying newly created public SSH key
        echo "\e[32m[INFO]\e[0m Displaying new SSH key at $SSH_KEY_PATH.pub"
        cat "$SSH_KEY_PATH.pub"
        # shellcheck disable=2034
        read ANSWER
        unset ANSWER

        [ -n "$HOST" ] && {
            # Adding key to the given host's authorized keys as each provided
            # user
            echo "\e[32m[INFO]\e[0m Copying key $SSH_KEY_PATH.pub to hosts"
            for SSH_USER in "$@"; do
                copy_key "$SSH_USER" "$HOST" "$SSH_KEY_PATH.pub"
            done
        }
        unset SSH_KEY_FILE_NAME SSH_KEY_PATH
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
unset CREATE_SSH_KEYS

#######################################
# Changing git origin of this repo
#######################################

# If remote origin is https, it's not ssh
echo "$GIT_ORIGIN" | grep 'https' > /dev/null 2>&1 && {
    echo '\e[32m[INFO]\e[0m Changing this repository remote to use SSH'

    # Changing this repository URL to use SSH
    echo "$GIT_ORIGIN" | \
        sed -E -e 's|https://(.+?)/(.+?)/(.+?)(.git)?|git@\1:\2/\3.git|' \
            -e 's/(\.git)+$/.git/g' \
        | xargs git remote set-url origin

    # Changing this repository URL hostname to use the correct SSH key
    echo '\e[32m[INFO]\e[0m Changing this repository URL hostname to use the' \
        ' correct SSH key'
    case "$HOST" in
        *'work'*)
            echo "$GIT_ORIGIN" | sed 's/@github.com/@personal.github.com/' \
                | xargs git remote set-url origin
            ;;
    esac
}

#######################################
# Creating gpg keys
#######################################

echo '\e[32m[INFO]\e[0m Creating gpg keys'

# Prompting the user for gpg key creation
printf 'Do you want to create gpg keys? [y/n] '
read CREATE_GPG_KEYS

case "$(echo "$CREATE_GPG_KEYS" | tr '[:upper:]' '[:lower:]')" in

    # Creating gpg keys
    'y'|'yes')

        # Prompting the user for the name associated to the gpg key
        printf 'Enter the gpg key name: '
        read GPG_NAME

        # Prompting the user for the email associated to the gpg key
        printf 'Enter the gpg email: '
        read GPG_EMAIL

        # Removing and displaying temporary parameter file for gpg batch mode
        echo '\e[32m[INFO]\e[0m Generating gpg keys with these parameters:'
        GPG_ARGS="$(mktemp)"
        tee "$GPG_ARGS" <<EOF
Key-Type: 1
Key-Length: 4096
Expire-Date: 0
Name-Real: $GPG_NAME
Name-Email: $GPG_EMAIL
EOF
        # Generating gpg key
        gpg --batch --generate-key "$GPG_ARGS"

        # Removing temporary parameter file for gpg batch mode
        echo '\e[32m[INFO]\e[0m Deleting temporary gpg parameter file'
        rm "$GPG_ARGS"

        # Displaying the public gpg key
        echo '\e[32m[INFO]\e[0m This is the newly created public gpg key'
        # Actually getting the content to paste on GitHub
        gpg --list-secret-keys --with-colons | grep 'sec' | cut -d ':' -f 5 \
            | xargs gpg --armor --export
        # shellcheck disable=2034
        read ANSWER
        unset ANSWER

        unset GPG_ARGS GPG_EMAIL GPG_NAME
        ;;

    # Not creating gpg keys
    'n'|'no')
        echo "OK. Gpg keys won't be created"
        ;;

    # Rejecting any other anser
    *)
        echo >&2 "Invalid answer: $CREATE_GPG_KEYS"
        exit 1
        ;;
esac
unset CREATE_GPG_KEYS
