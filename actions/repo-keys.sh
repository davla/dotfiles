#!/usr/bin/env sh

# This script installs repository keys

#######################################
# Repositoy keys
#######################################

# 379CE192D401AB61 --> Etcher
# 0AB215679C571D1C8325275B9BDB3D89CE49EC21 --> Firefox beta
# C6ABDCF64DB9A0B2 --> Slack
# 931FF8E79F0876134EDDBDCCA87FF9DF48BF1C90 --> Spotify
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys \
    '0AB215679C571D1C8325275B9BDB3D89CE49EC21' '379CE192D401AB61' \
    'C6ABDCF64DB9A0B2' '931FF8E79F0876134EDDBDCCA87FF9DF48BF1C90' \
    | apt-key add -
wget -qO - 'https://packagecloud.io/AtomEditor/atom/gpgkey' | apt-key add -
apt-key adv --keyserver pgp.mit.edu --recv-keys 5044912E | apt-key add -
wget -qO - 'https://download.docker.com/linux/debian/gpg' | apt-key add -
wget -qO - 'https://dl.sinew.in/keys/enpass-linux.key' | apt-key add -
wget -qO - 'https://cli-assets.heroku.com/apt/release.key' | apt-key add -
wget -qO - 'https://repo.skype.com/data/SKYPE-GPG-KEY' | apt-key add -
wget -qO - 'https://www.virtualbox.org/download/oracle_vbox_2016.asc' | \
    apt-key add -
wget -qO - 'https://dl.yarnpkg.com/debian/pubkey.gpg' | apt-key add -
apt-get update -oAcquire::AllowInsecureRepositories=true
apt-get install -oAcquire::AllowInsecureRepositories=true \
    deb-multimedia-keyring
