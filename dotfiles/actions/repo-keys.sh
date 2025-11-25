#!/usr/bin/env sh

# This script installs apt repository keys for the *.sources files found in
# /etc/apt/sources.list.d
#
# Arguments:
#   - $1: The directory where APT repository signature files should be saved

# This doesn't work if this script is sourced
. "$(dirname "$0")/../../bot-steps/lib.sh"

########################################
# Input processing
########################################

APT_KEY_DIR="$1"

########################################
# Functions
########################################

# This function downloads an APT key from a keyserver and installs it into the
# APT trusted GPG keys directory.
#
# Arguments:
#   - $1: The repository name, used as a name for the GPG key file.
#   - $2: The GPG key to download.
#   - $3: The keyserver to use. Defaults to 'hkp://keyserver.ubuntu.com:80'.
download_key_from_keyserver() {
    DL_SRV_REPO_NAME="$1"
    DL_SRV_KEY="$2"
    DL_SRV_KEYSERVER="${3:-hkp://keyserver.ubuntu.com:80}"

    print_info "Installing apt repository key for $REPO"
    gpg --keyserver "$DL_SRV_KEYSERVER" --recv-keys "$DL_SRV_KEY"
    gpg --export "$DL_SRV_KEY" > "$APT_KEY_DIR/$DL_SRV_REPO_NAME.gpg"

    unset DL_SRV_KEY DL_SRV_KEYSERVER DL_SRV_REPO_NAME
}

# This function downloads an APT key from a URL and installs it into the APT
# trusted GPG keys directory.
#
# Arguments:
#   - $1: The repository name, used as a name for the GPG key file.
#   - $2: The URL of the GPG key to download.
download_key_from_url() {
    DL_URL_REPO_NAME="$1"
    DL_URL_REPO_KEY_URL="$2"

    print_info "Installing apt repository key for $DL_URL_REPO_NAME"
    wget "$DL_URL_REPO_KEY_URL" --output-document - | gpg --dearmor --yes \
        -o "$APT_KEY_DIR/$DL_URL_REPO_NAME.gpg"

    unset DL_URL_KEY_EXT DL_URL_REPO_KEY_URL DL_URL_REPO_NAME
}

#######################################
# Repositoy keys
#######################################

# Ensure the APT repository signatures directory exists
mkdir --parents "$APT_KEY_DIR"

# Set temporary gpg keyring to import apt keys from keyservers
OLD_GNUPGHOME="$GNUPGHOME"
GNUPGHOME="$(mktemp --directory)"

find /etc/apt/sources.list.d/ -type f -name '*.sources' -print0 \
    | xargs --null -I '{}' basename '{}' '.sources' \
    | tr '[:upper:]' '[:lower:]' \
    | while read -r REPO; do
        case "$REPO" in
            'docker')
                download_key_from_url "$REPO" \
                    'https://download.docker.com/linux/debian/gpg'
                ;;

            'dropbox')
                download_key_from_keyserver "$REPO" '5044912E' \
                    'hkp://pgp.mit.edu:80'
                ;;

            'firefox')
                download_key_from_url "$REPO" \
                    'https://packages.mozilla.org/apt/repo-signing-key.gpg'
                ;;

            'nordvpn')
                download_key_from_url "$REPO" \
                    'https://repo.nordvpn.com/gpg/nordvpn_public.asc'
                ;;

            'spotify')
                download_key_from_url "$REPO" \
                    'https://download.spotify.com/debian/pubkey_C85668DF69375001.gpg'
                ;;

            'vscode')
                download_key_from_url "$REPO" \
                    'https://packages.microsoft.com/keys/microsoft.asc'
                ;;
        esac 2> /dev/null
    done

# Restore GNUPGHOME
GNUPGHOME="$OLD_GNUPGHOME"
rm --force --recursive "$OLD_GNUPGHOME"
unset OLD_GNUPGHOME
