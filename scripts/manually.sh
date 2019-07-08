#!/usr/bin/env sh

# This script installs manually managed packages and applications.

#######################################
# Variables
#######################################

TELEGRAM_ARCH='telegram.tar.xz'
TELEGRAM_HOME='/opt/telegram'

#######################################
# Input processing
#######################################

USER_NAME="${1:-$USER}"

#######################################
# Telegram
#######################################

# Installing the executables
mkdir -p "$TELEGRAM_HOME"
wget 'https://tdesktop.com/linux' -O "$TELEGRAM_ARCH"
tar -xf "$TELEGRAM_ARCH" -C "$TELEGRAM_HOME" --strip-components=1
rm "$TELEGRAM_ARCH"

# Linking the main executable in $PATH
ln -sf "$TELEGRAM_HOME/Telegram" '/usr/local/bin/telegram'

# Making updater work also for unprivileged users in telegram group
groupadd -f telegram
getent passwd telegram > /dev/null 2>&1 || useradd -r -g telegram telegram
usermod -aG telegram "$USER_NAME"
# Setting telegram user login group to telegram, even if the user is not
# created above
usermod -g telegram telegram
chown telegram:telegram -R "$TELEGRAM_HOME"

#######################################
# Dotfiles installation
#######################################

dotdrop install -p manual

#!/usr/bin/env bash

# This scripts sets up the machinery for manually installing and updating
# applications that aren't packages in a repository. It then uses such
# machinery immediately to install them.
#
# Arguments:
#   - $1: The base directory where the manual install machinery will be
#       installed. It's read also from the environment variable
#       MANUAL_INST_BASE, and defaults to /usr/local/lib/manual-install

# Every application should define the following functions:
#   - is-installed: Exits with 0 if the application is installed,
#       non-zero otherwise.
#   - install: Installs the application.
#   - installed-version: Prints the installed version on STDOUT.
#   - latest-version: Prints the latest available version on STDOUT.
#   - is-newer <v1> <v2>: Exits with 0 if v1 equal or newer than v2, non-zero
#       otherwise.
#   - remove: Removes the application.
#
# Such functions should be defined inside *.inst files, located in the
# directory functions.d under the machinery installation path.

#####################################################
#
#                   Variables
#
#####################################################

# Absolute path of this script's parent directory
PARENT_DIR="$(dirname "${BASH_SOURCE[0]}")"
MANUAL_INST_LIB_DIR="$PARENT_DIR/lib/manual-install"

#####################################################
#
#               Input processing
#
#####################################################

# Machinery directories
MANUAL_INST_DIR="${MANUAL_INST_BASE:-/usr/local/lib/manual-install}"
[[ -n "$1" ]] && MANUAL_INST_DIR="$1"
MANUAL_INST_FUNCTIONS_DIR="$MANUAL_INST_DIR/functions.d"
MANUAL_INST_LOG_DIR="$MANUAL_INST_DIR/log"

#####################################################
#
#               Machinery setup
#
#####################################################

mkdir -p "$MANUAL_INST_DIR" "$MANUAL_INST_FUNCTIONS_DIR" "$MANUAL_INST_LOG_DIR"

cp "$MANUAL_INST_LIB_DIR/lib.sh" "$MANUAL_INST_DIR"
cp "$MANUAL_INST_LIB_DIR/"*.inst "$MANUAL_INST_FUNCTIONS_DIR"

#####################################################
#
#               Manual installations
#
#####################################################

bash "$PARENT_DIR/custom-commands.sh" manual-install
manual-install -f -b "$MANUAL_INST_DIR"
