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
sudo adduser "$USER" docker

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

git clone 'https://github.com/davla/n.git' "$N_DIR"
sudo make -C "$N_DIR" install
make -C "$N_DIR" use
rm -rf "$N_DIR"

sudo n latest
sudo cp -r Support/n/* /usr/local/n/versions/node
