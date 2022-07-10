#!/usr/bin/env sh

# This script installs cursor, desktop and icon themes.
#
# Arguments:
#   - $1: Cursor themes archive.
#   - $2: Desktop themes archive.
#   - $3: Icons themes archive.

# This doesn't work if this script is sourced
. "$(dirname "$0")/lib.sh"

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

    print_info "Retrieve $ARCHIVE_NAME archive path" >&2
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

print_info 'Install cursor themes'

mkdir -p "$CURSORS_PATH"

# Install custom cursors themes
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

print_info 'Install desktop themes'

mkdir -p "$DESKTOP_PATH"

# Installing custom cursors themes
tar -xjf "$DESKTOP_ARCH" -C "$DESKTOP_PATH"

#######################################
# Icon themes
#######################################

print_info 'Install icon themes'

mkdir -p "$ICONS_PATH"

# Install icons cursors themes
tar -xjf "$ICONS_ARCH" -C "$ICONS_PATH"

# Create icon cache for the newly installed icons
print_info 'Creating icon themes cache'
tar -tjf "$ICONS_ARCH" --exclude='*/*' \
    | xargs -n 1 -I '{}' gtk-update-icon-cache "$ICONS_PATH/{}"
