#!/usr/bin/env bash

# Deals with themes and icons:
#   - sets the look and feel of the login screen
# 	- restores themes from an archive
# 	- restores ACYLS colorized icon themes
#	- restores too many cursor themes

# Arguments:
#   - $1: the themes archive
#   - $2: the ACYLS and cursors archive

# Orage panel clock formats
# Line 1: %H:%M:%S
# Line 2: %d-%m-%Y
# Tooltip: %A, %d %B %Y

#####################################################
#
#                   Variables
#
#####################################################

# Absolute path of this script's parent directory
PARENT_DIR="$(dirname "${BASH_SOURCE[0]}")"
LIB_DIR="$PARENT_DIR/lib"

#####################################################
#
#               Input processing
#
#####################################################

THEMES_ARCH="$1"
ICONS_ARCH="$2"

# Cannot proceed if any od the two input files does not exist
if [[ ! -f "$THEMES_ARCH" || ! -f "$ICONS_ARCH" ]]; then
	echo 'Themes or icons archives not found!'
	exit 1
fi

#####################################################
#
#                   Login screen
#
#####################################################

LIGHTDM_CONF_BASE='/usr/share/lightdm'
LIGHTDM_CONF_DIR="$LIGHTDM_CONF_BASE/lightdm.conf.d"
LIGHTDM_GREETER_CONF_DIR="$LIGHTDM_CONF_BASE/lightdm-gtk-greeter.conf.d"

sudo mkdir -p "$LIGHTDM_CONF_DIR"
sudo cp "$LIB_DIR/lightdm/02_lightdm_custom.conf" "$LIGHTDM_CONF_DIR"

sudo mkdir -p "$LIGHTDM_GREETER_CONF_DIR"
sudo cp "$LIB_DIR/lightdm/02_greeter_custom.conf" "$LIGHTDM_GREETER_CONF_DIR"

#####################################################
#
#                      Themes
#
#####################################################

sudo tar -xjf "$THEMES_ARCH" -C /usr/share/themes
[[ $? -ne 0 ]] && exit 1
echo 'Themes installed'

#####################################################
#
#                   ACYLS & Cursors
#
#####################################################

# Creating icons path if not existing
ICONS_PATH="$HOME/.icons"
mkdir -p "$ICONS_PATH"

# Installung custom cursors themes
tar -xjf "$ICONS_ARCH" -C "$ICONS_PATH"
[[ $? -ne 0 ]] && exit 1

# Creating icon cache for the newly installed icons
find "$ICONS_PATH" -maxdepth 1 -type d -name 'ACYLS*' \
    -exec gtk-update-icon-cache {} \; &> /dev/null
echo 'ACYLS and cursors installed'

# Old cursors
# "http://xfce-look.org/CONTENT/content-files/145644-X-Steel-GRAY-negative.tar.gz" # X-Steel-Gray-negative
# "https://www.dropbox.com/s/9rizmm5rvq5wf00/RingBlue.tgz" # Ring Blue
# "https://www.dropbox.com/s/kpqp5d98leb161l/RingGreen.tgz" # Ring Green
# "https://www.dropbox.com/s/48u0utzbo578qck/RingOrange.tgz" # Ring Orange
# "https://www.dropbox.com/s/1cvz8kvh6nviju5/RingRed.tgz" # Ring Red
# "https://www.dropbox.com/s/s78ksb15ot8rs8j/RingWhite.tgz" # Ring White
