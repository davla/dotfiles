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
            'atom')
                echo "Installing apt repository key for $REPO"

                wget -qO - 'https://packagecloud.io/AtomEditor/atom/gpgkey' \
                    | apt-key add - > /dev/null
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

            'enpass')
                echo "Installing apt repository key for $REPO"

                apt-key adv --fetch-keys \
                    'https://dl.sinew.in/keys/enpass-linux.key' > /dev/null
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

            'heroku')
                echo "Installing apt repository key for $REPO"

                apt-key adv --fetch-keys \
                    'https://cli-assets.heroku.com/apt/release.key' > /dev/null
                ;;

            'skype-stable')
                echo "Installing apt repository key for $REPO"

                apt-key adv --fetch-keys \
                    'https://repo.skype.com/data/SKYPE-GPG-KEY' > /dev/null
                ;;

            'slack')
                echo "Installing apt repository key for $REPO"

                apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' \
                    --recv-keys 'C6ABDCF64DB9A0B2' > /dev/null
                ;;

            'spotify')
                echo "Installing apt repository key for $REPO"

                apt-key adv --fetch-keys \
                    'https://download.spotify.com/debian/pubkey.gpg' \
                    > /dev/null
                ;;

            'virtualbox')
                echo "Installing apt repository key for $REPO"

                apt-key adv --fetch-keys \
                    'https://www.virtualbox.org/download/oracle_vbox_2016.asc' \
                    > /dev/null
                ;;

            'vscode')
                echo "Installing apt repository key for $REPO"

                apt-key adv --fetch-keys \
                    'https://packages.microsoft.com/keys/microsoft.asc' \
                    > /dev/null
                ;;

            'yarn')
                echo "Installing apt repository key for $REPO"

                apt-key adv --fetch-keys \
                    'https://dl.yarnpkg.com/debian/pubkey.gpg' > /dev/null
                ;;
        esac 2> /dev/null
    done
