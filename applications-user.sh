#!/usr/bin/env bash

# This script installs and sets up applications as a non-root
# user. Some applications are installed system wide as root,
# and just the setup for any other user is done here; some
# other applications are installed here, since they require so.

#####################################################
#
#               User application setup
#
#####################################################

# Docker
DOCKER_USER_CONFIG="$HOME/.docker"
DOCKER_CONFIG_FILE="$HOME/.docker/config.json"

sudo adduser "$USER" docker

mkdir -p "$DOCKER_USER_CONFIG"
# Adding "credsStore" key if the configuration file already exists, otherwise
# creating it from scratch with the same key.
[[ -f "$DOCKER_CONFIG_FILE" ]] \
    && jq '.credsStore = "secretService"' "$DOCKER_CONFIG_FILE" | \
        sponge "$DOCKER_CONFIG_FILE" \
    || jq -n '{credsStore: "secretService"}' > "$DOCKER_CONFIG_FILE"

# GHC
echo ':set prompt "ghci> "' > "$HOME/.ghci"

# Git
git config --global user.name 'Davide Laezza'
git config --global user.email 'truzzialrogo@gmx.com'
git config --global credential.helper /usr/bin/git-credential-gnome-keyring

#####################################################
#
#           User application installation
#
#####################################################

# Telegram
TELEGRAM_ARCH='telegram.tar.xz'
TELEGRAM_HOME="$HOME/.TelegramDesktop"

mkdir -p "$TELEGRAM_HOME"
wget 'https://tdesktop.com/linux' -O "$TELEGRAM_ARCH"
tar -xf "$TELEGRAM_ARCH" -C "$TELEGRAM_HOME" --strip-components=1
rm "$TELEGRAM_ARCH"
sudo bash bin-symlinks.sh

# Executing Telegram once to automatically
# create .desktop file: "for reasons unknown"
# if done via 'telegram' symlink it desn't work
"$TELEGRAM_HOME/Telegram"

# N
# Even though it must be installed as root, the n use wrapper is user-based,
# hence N is installed here
N_DIR='/tmp/n'

git clone 'git@github.com:davla/n.git' "$N_DIR"
sudo make -C "$N_DIR" install
make -C "$N_DIR" use
rm -rf "$N_DIR"

sudo n latest
sudo cp -r Support/n/* /usr/local/n/versions/node
