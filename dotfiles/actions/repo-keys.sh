#!/usr/bin/env sh

# This script installs apt repository keys for the *.list files found in
# /etc/apt/sources.list.d

#######################################
# Repositoy keys
#######################################

find /etc/apt/sources.list.d/ -type f -name '*.list' -print0 \
    | xargs -0 -i basename '{}' '.list' | tr '[:upper:]' '[:lower:]' \
    | while read REPO; do
        case "$REPO" in
            'android-studio')
                echo "Installing apt repository key for $REPO"

                apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' \
                    --recv-keys 'ADC23DDFAE0436477B8CCDF54DEA8909DC6A13A3' \
                    > /dev/null
                ;;

            'azure-cli')
                echo "Installing apt repository key for $REPO"

                apt-key adv --fetch-keys \
                    'https://packages.microsoft.com/keys/microsoft.asc' \
                    > /dev/null
                ;;

            'chromium-dev')
                echo "Installing apt repository key for $REPO"

                apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' \
                    --recv-keys 'EA6E302DC78CC4B087CFC3570EBEA9B02842F111' \
                    > /dev/null
                ;;

            'deb-multimedia')
                echo "Installing apt repository key for $REPO"

                apt-get update -oAcquire::AllowInsecureRepositories=true \
                    > /dev/null
                apt-get install -oAcquire::AllowInsecureRepositories=true \
                    deb-multimedia-keyring > /dev/null
                ;;

            'docker')
                echo "Installing apt repository key for $REPO"

                apt-key adv --fetch-keys \
                    'https://download.docker.com/linux/debian/gpg' > /dev/null
                ;;

            'dropbox')
                echo "Installing apt repository key for $REPO"

                apt-key adv --keyserver 'hkp://pgp.mit.edu:80' \
                    --recv-keys '1C61A2656FB57B7E4DE0F4C1FC918B335044912E' \
                    > /dev/null
                ;;

            'etcher')
                echo "Installing apt repository key for $REPO"

                apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' \
                    --recv-keys '379CE192D401AB61' > /dev/null
                ;;

            'firefox-beta')
                echo "Installing apt repository key for $REPO"

                apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' \
                    --recv-keys '0AB215679C571D1C8325275B9BDB3D89CE49EC21' \
                    > /dev/null
                ;;

            'spotify')
                echo "Installing apt repository key for $REPO"

                apt-key adv --fetch-keys \
                    'https://download.spotify.com/debian/pubkey_0D811D58.gp' \
                    > /dev/null
                ;;

            'teams')
                echo "Installing apt repository key for $REPO"

                apt-key adv --fetch-keys \
                    'https://packages.microsoft.com/keys/microsoft.asc' \
                    > /dev/null
                ;;

            'vscode')
                echo "Installing apt repository key for $REPO"

                apt-key adv --fetch-keys \
                    'https://packages.microsoft.com/keys/microsoft.asc' \
                    > /dev/null
                ;;
        esac 2> /dev/null
    done
