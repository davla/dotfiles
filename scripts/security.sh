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
. "$(dirname "$0")/lib.sh"

#######################################
# Variables
#######################################

# Git origin remote URL
GIT_ORIGIN="$(git remote get-url origin)"

# SSH base directory
SSH_HOME="$HOME/.ssh"

# Default value for SSH key file name
DEFAULT_SSH_KEY='id_rsa'

########################################
# Functions
########################################

# This function prompts the user to enter the name of an SSH key. It uses a
# default value if the user enters nothing. Returns the full path of the key
# in $SSH_HOME
#
# Arguments:
#   - $1: The file descriptor the prompts are output to.
prompt_ssh_key_name() {
    PROMPT_SSH_OUTPUT="$1"

    printf "Enter SSH key filename [default '%s']: " "$DEFAULT_SSH_KEY" \
        >&"$PROMPT_SSH_OUTPUT"
    read -r PROMPT_SSH_FILE_NAME
    echo "$SSH_HOME/${PROMPT_SSH_FILE_NAME:-$DEFAULT_SSH_KEY}"

    unset PROMPT_SSH_FILE_NAME PROMPT_SSH_OUTPUT
}

#######################################
# Input processing
#######################################

[ $# -gt 0 ] && {
    SSH_SERVER="$1"
    # This discards the only CLI argument that is not an user name
    shift
}

#######################################
# Create SSH keys
#######################################

print_info "Ensure $SSH_HOME exists"
mkdir -p "$SSH_HOME"

# Prompt the user for SSH key creation
printf 'Do you want to create ssh keys? [y/n] '
read -r CREATE_SSH_KEYS

case "$(echo "$CREATE_SSH_KEYS" | tr '[:upper:]' '[:lower:]')" in

    # Create SSH key
    'y'|'yes')
        print_info 'Create SSH key'

        # Create the SSH key (interactive)
        exec 3>&1
        SSH_KEY_PATH="$(prompt_ssh_key_name '3')"
        exec 3>&-
        ssh-keygen -f "$SSH_KEY_PATH" -t rsa

        # Add the newly created SSH key to gpg-agent (interactive)
        print_info "Add new SSH key at $SSH_KEY_PATH to gpg-agent"
        ssh-add "$SSH_KEY_PATH"

        # Display newly created public SSH key
        print_info "Display new SSH key at $SSH_KEY_PATH.pub"
        cat "$SSH_KEY_PATH.pub"
        read -r

        # Leaving SSH_KEY_PATH around for later use.
        unset SSH_KEY_FILE_NAME
        ;;

    # Not generate SSH key
    'n'|'no')
        echo "OK. SSH keys won't be created"
        ;;

    # Reject any other answer
    *)
        echo >&2 "Invalid answer: $CREATE_SSH_KEYS"
        exit 1
        ;;
esac
unset CREATE_SSH_KEYS

########################################
# Copy SSH keys to servers
########################################

[ -n "$SSH_SERVER" ] && {
    # Prompt for SSH key name if not done yet
    exec 3>&1
    SSH_KEY_PATH="${SSH_KEY_PATH:-"$(prompt_ssh_key_name '3')"}"
    exec 3>&-

    # Add key to the given host's authorized keys as each provided user
    print_info "Copy key $SSH_KEY_PATH.pub to servers"

    for SSH_USER in "$@"; do
        ssh-copy-id -i "$SSH_KEY_PATH.pub" "$SSH_USER@$SSH_SERVER"
    done
}

unset SSH_KEY_PATH

#######################################
# Change git origin of this repo
#######################################

# If remote origin is https, it's not ssh
echo "$GIT_ORIGIN" | grep -E 'https?' > /dev/null 2>&1 && {
    print_info 'Change this repository remote to use SSH'

    # Change this repository URL to use SSH
    echo "$GIT_ORIGIN" | \
        sed -E -e 's|https?://(.+?)/(.+?)/(.+?)(.git)?|git@\1:\2/\3.git|' \
            -e 's/(\.git)+$/.git/g' \
        | xargs git remote set-url origin

    case "$HOST" in
        *'work'*)
            # Change this repository URL hostname to use the correct SSH key
            print_info -n 'Change this repository URL hostname to use the '
            echo 'correct SSH key'
            # The remote might have just been changed, hence $GIT_ORIGIN is
            # stale and the git origin url needs to be queried again
            git remote get-url origin \
                | sed 's/@github.com/@personal.github.com/' \
                | xargs git remote set-url origin
            ;;
    esac
}

#######################################
# Create gpg keys
#######################################

print_info 'Create gpg keys'

# Prompt the user for gpg key creation
printf 'Do you want to create gpg keys? [y/n] '
read -r CREATE_GPG_KEYS

case "$(echo "$CREATE_GPG_KEYS" | tr '[:upper:]' '[:lower:]')" in

    # Create gpg keys
    'y'|'yes')
        print_info 'Create gpg key'

        # Prompt the user for the name associated to the gpg key
        printf 'Enter the gpg key name: '
        read -r GPG_NAME

        # Prompt the user for the email associated to the gpg key
        printf 'Enter the gpg email: '
        read -r GPG_EMAIL

        # Display temporary parameter file for gpg batch mode
        print_info 'Generate gpg keys with these parameters:'
        GPG_ARGS="$(mktemp)"
        tee "$GPG_ARGS" <<EOF
Key-Type: 1
Key-Length: 4096
Expire-Date: 0
Name-Real: $GPG_NAME
Name-Email: $GPG_EMAIL
EOF
        # Generate gpg key
        gpg --batch --generate-key "$GPG_ARGS"

        # Remove temporary parameter file for gpg batch mode
        rm "$GPG_ARGS"

        print_info 'Display new public gpg key'
        # Actually get the content to paste on GitHub
        gpg --list-secret-keys --with-colons | grep 'sec' | cut -d ':' -f 5 \
            | xargs gpg --armor --export
        read -r

        unset GPG_ARGS GPG_EMAIL GPG_NAME
        ;;

    # Not create gpg keys
    'n'|'no')
        echo "OK. Gpg keys won't be created"
        ;;

    # Reject any other anser
    *)
        echo >&2 "Invalid answer: $CREATE_GPG_KEYS"
        exit 1
        ;;
esac
unset CREATE_GPG_KEYS
