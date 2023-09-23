#!/usr/bin/env sh

# This script installs apt repository keys for the *.list files found in
# /etc/apt/sources.list.d

# This doesn't work if this script is sourced
. "$(dirname "$0")/../../scripts/lib.sh"

#######################################
# Repositoy keys
#######################################

find /etc/apt/sources.list.d/ -type f -name '*.list' -print0 \
    | xargs -0 -I '{}' basename '{}' '.list' | tr '[:upper:]' '[:lower:]' \
    | while read -r REPO; do
        case "$REPO" in
            'alacritty')
                print_info "Installing apt repository key for $REPO"

                apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' \
                    --recv-keys '3A160895CC2CE253085D08A552B24DF7D43B5377' \
                    > /dev/null
                ;;

            'deb-multimedia')
                print_info "Installing apt repository key for $REPO"

                apt-get update -oAcquire::AllowInsecureRepositories=true \
                    > /dev/null
                apt-get install -oAcquire::AllowInsecureRepositories=true \
                    deb-multimedia-keyring > /dev/null
                ;;

            'docker')
                print_info "Installing apt repository key for $REPO"

                apt-key adv --fetch-keys \
                    'https://download.docker.com/linux/debian/gpg' > /dev/null
                ;;

            'dropbox')
                print_info "Installing apt repository key for $REPO"

                apt-key adv --keyserver 'hkp://pgp.mit.edu:80' \
                    --recv-keys '1C61A2656FB57B7E4DE0F4C1FC918B335044912E' \
                    > /dev/null
                ;;

            'firefox-beta')
                print_info "Installing apt repository key for $REPO"

                apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' \
                    --recv-keys '0AB215679C571D1C8325275B9BDB3D89CE49EC21' \
                    > /dev/null
                ;;

            'mono')
                print_info "Installing apt repository key for $REPO"

                apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' \
                    --recv-keys '3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF' \
                    > /dev/null
                ;;

            'spotify')
                print_info "Installing apt repository key for $REPO"

                apt-key adv --fetch-keys \
                    'https://download.spotify.com/debian/pubkey_5E3C45D7B312C643.gpg' \
                    > /dev/null
                ;;

            'azure-cli'|'microsoft-prod'|'teams'|'vscode')
                print_info "Installing apt repository key for $REPO"

                apt-key adv --fetch-keys \
                    'https://packages.microsoft.com/keys/microsoft.asc' \
                    > /dev/null
                ;;
        esac 2> /dev/null
    done
