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
read -r CREATE_SSH_KEYS

case "$(echo "$CREATE_SSH_KEYS" | tr '[:upper:]' '[:lower:]')" in

    # Creating SSH key
    'y'|'yes')
        echo '\e[32m[INFO]\e[0m Creating SSH key'

        # Prompting the user for SSH key filename, handling the default too
        printf "Enter SSH key filename [default '%s']: " "$DEFAULT_SSH_KEY"
        read -r SSH_KEY_FILE_NAME
        [ -z "$SSH_KEY_FILE_NAME" ] && SSH_KEY_FILE_NAME="$DEFAULT_SSH_KEY"

        # Actually creating the SSH key (interactive)
        SSH_KEY_PATH="$SSH_HOME/$SSH_KEY_FILE_NAME"
        ssh-keygen -f "$SSH_KEY_PATH" -t rsa

        # Adding the newly created SSH key to gpg-agent (interactive)
        printf '\e[32m[INFO]\e[0m Adding new SSH key at %s to ' "$SSH_KEY_PATH"
        echo 'gpg-agent'
        ssh-add "$SSH_KEY_PATH"

        # Displaying newly created public SSH key
        echo "\e[32m[INFO]\e[0m Displaying new SSH key at $SSH_KEY_PATH.pub"
        cat "$SSH_KEY_PATH.pub"
        # shellcheck disable=2034
        read -r ANSWER
        unset ANSWER

        [ -n "$HOST" ] && {
            # Adding key to the given host's authorized keys as each provided
            # user
            echo "\e[32m[INFO]\e[0m Copying key $SSH_KEY_PATH.pub to hosts"
            for SSH_USER in "$@"; do
                ssh-copy-id -i "$SSH_KEY_PATH.pub" "$SSH_USER@$HOST"
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
echo "$GIT_ORIGIN" | grep -E 'https?' > /dev/null 2>&1 && {
    echo '\e[32m[INFO]\e[0m Changing this repository remote to use SSH'

    # Changing this repository URL to use SSH
    echo "$GIT_ORIGIN" | \
        sed -E -e 's|https?://(.+?)/(.+?)/(.+?)(.git)?|git@\1:\2/\3.git|' \
            -e 's/(\.git)+$/.git/g' \
        | xargs git remote set-url origin

    case "$HOST" in
        *'work'*)
            # Changing this repository URL hostname to use the correct SSH key
            echo '\e[32m[INFO]\e[0m Changing this repository URL hostname to '
                'use the correct SSH key'
            # The remote might have just been changed, hence $GIT_ORIGIN is
            # stale and the git origin url needs to be queried again
            git remote get-url origin \
                | sed 's/@github.com/@personal.github.com/' \
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
read -r CREATE_GPG_KEYS

case "$(echo "$CREATE_GPG_KEYS" | tr '[:upper:]' '[:lower:]')" in

    # Creating gpg keys
    'y'|'yes')

        # Prompting the user for the name associated to the gpg key
        printf 'Enter the gpg key name: '
        read -r GPG_NAME

        # Prompting the user for the email associated to the gpg key
        printf 'Enter the gpg email: '
        read -r GPG_EMAIL

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
        read -r ANSWER
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
