#!/usr/bin/env bash

# Deals with themes and icons:
# 	- installs murrine theme engine
# 	- restores themes from an archive
# 	- installs ACYL icon theme
#	- restores too many cursor themes

# Arguments:
#   - $1: the themes archive
#   - $2: the cursor archive

# Orage panel clock formats
# Line 1: %H:%M:%S
# Line 2: %d-%m-%Y
# Tooltip: %A, %d %B %Y

#####################################################
#
#               Input processing
#
#####################################################

THEMES_ARCH="$1"
CURSORS_ARCH="$2"

if [[ ! -f "$THEMES_ARCH" || ! -f "$CURSORS_ARCH" ]]; then
	echo 'Themes or icons directory not found!'
	exit 1
fi

#####################################################
#
#                      Themes
#
#####################################################

# Managing Preinstalled packages
#sudo apt-get install gtk2-engines-murrine
#sudo apt-get purge gnome-themes-standard-data
#sudo apt-get purge murrine-themes
#sudo apt-get purge gtk2-engines

# Installing custom themes
sudo tar -xjf "$THEMES_ARCH" -C /usr/share/themes
[[ $? -ne 0 ]] && exit 1 || echo 'Themes installed'

#####################################################
#
#       Any Color You Like (aka ACYL)
#
#####################################################

sudo apt-get install acyl-icon-set
[[ $? -ne 0 ]] && exit 1 || echo 'ACYL installed'

#####################################################
#
#                       Cursor
#
#####################################################

# Creating icons path if not existing
ICONS_PATH="$HOME/.icons"
mkdir -p "$ICONS_PATH"

# Installung custom cursors themes
tar -xjf "$CURSORS_ARCH" -C "$ICONS_PATH"
[[ $? -ne 0 ]] && exit 1 || echo 'Cursors installed'

# Old cursors
# "http://xfce-look.org/CONTENT/content-files/145644-X-Steel-GRAY-negative.tar.gz" # X-Steel-Gray-negative
# "https://www.dropbox.com/s/9rizmm5rvq5wf00/RingBlue.tgz" # Ring Blue
# "https://www.dropbox.com/s/kpqp5d98leb161l/RingGreen.tgz" # Ring Green
# "https://www.dropbox.com/s/48u0utzbo578qck/RingOrange.tgz" # Ring Orange
# "https://www.dropbox.com/s/1cvz8kvh6nviju5/RingRed.tgz" # Ring Red
# "https://www.dropbox.com/s/s78ksb15ot8rs8j/RingWhite.tgz" # Ring White

echo 'Everything got installed. Good job!'
