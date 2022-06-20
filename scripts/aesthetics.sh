#!/usr/bin/env sh

# This script installs cursor, desktop and icon themes.
#
# Arguments:
#   - $1: Cursor themes archive.
#   - $2: Desktop themes archive.
#   - $3: Icons themes archive.

#######################################
# Variables
#######################################

# Path where themes are are installed
CURSORS_PATH="/usr/share/icons"
DESKTOP_PATH="/usr/share/themes"
ICONS_PATH="/usr/share/icons"

#######################################
# Functions
#######################################

# This function retrieves an archive path. If the input is the empty string,
# it prompts the user for a path. Exits with an error the the input path is not
# a file.
#
# Arguments:
#   - $1: Archive path. Can be the empty string
#   - $2: the archive name, used in prompt and error messages. Must be
#         capitalized.
get_archive() {
    ARCHIVE="$1"
    ARCHIVE_NAME="$2"

    [ -z "$ARCHIVE" ] && {
        echo "$ARCHIVE_NAME" | tr '[:upper:]' '[:lower:]' \
            | xargs printf >&2 'Enter the %s theme archive path: '
        read -r ARCHIVE
    }

    [ ! -f "$ARCHIVE" ] && {
        echo >&2 "$ARCHIVE_NAME theme archive file ($ARCHIVE) not found!"
        exit 1
    }

    echo "$ARCHIVE"
    unset ARCHIVE ARCHIVE_NAME
}

#######################################
# Input processing
#######################################

CURSORS_ARCH="$(get_archive "$1" 'Cursor')"
DESKTOP_ARCH="$(get_archive "$2" 'Desktop')"
ICONS_ARCH="$(get_archive "$3" 'Icons')"

#######################################
# Cursor themes
#######################################

# Creating cursor themes path if not existing
mkdir -p "$CURSORS_PATH"

# Installing custom cursors themes
echo "Installing cursor themes from $CURSORS_ARCH -> $CURSORS_PATH"
tar -xjf "$CURSORS_ARCH" -C "$CURSORS_PATH"

# Old cursors
# "http://xfce-look.org/CONTENT/content-files/145644-X-Steel-GRAY-negative.tar.gz" # X-Steel-Gray-negative
# "https://www.dropbox.com/s/9rizmm5rvq5wf00/RingBlue.tgz" # Ring Blue
# "https://www.dropbox.com/s/kpqp5d98leb161l/RingGreen.tgz" # Ring Green
# "https://www.dropbox.com/s/48u0utzbo578qck/RingOrange.tgz" # Ring Orange
# "https://www.dropbox.com/s/1cvz8kvh6nviju5/RingRed.tgz" # Ring Red
# "https://www.dropbox.com/s/s78ksb15ot8rs8j/RingWhite.tgz" # Ring White

#######################################
# Desktop themes
#######################################

# Creating desktop themes path if not existing
mkdir -p "$DESKTOP_PATH"

# Installing custom cursors themes
echo "Installing desktop themes from $DESKTOP_ARCH -> $DESKTOP_PATH"
tar -xjf "$DESKTOP_ARCH" -C "$DESKTOP_PATH"

#######################################
# Icon themes
#######################################

# Creating icons path if not existing
mkdir -p "$ICONS_PATH"

# Installing icons cursors themes
echo "Installing icon themes from $ICONS_ARCH -> $ICONS_PATH"
tar -xjf "$ICONS_ARCH" -C "$ICONS_PATH"

# Creating icon cache for the newly installed icons
echo 'Creating icon themes cache'
tar -tjf "$ICONS_ARCH" --exclude='*/*' \
    | xargs -n 1 -I '{}' gtk-update-icon-cache "$ICONS_PATH/{}"
