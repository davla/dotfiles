#!/usr/bin/env bash

# This script downloads Android SDK command line tools, unless they are already
# on the filesystem, and makes the binaries available on $PATH to all users in
# the android group.

# Arguments:
#   - -f: Flag. When set, forces the download of the sdk tools.
#   - $1: hash of the android sdk tools zip. Default to the latest one at the
#       time of writing (the same for over one year), that is 4333796.

#####################################################
#
#                   Privileges
#
#####################################################

# Checking for root privileges: if don't
# have them, recalling this script with sudo
if [[ $EUID -ne 0 ]]; then
    echo 'This script needs to be run as root'
    sudo bash "${BASH_SOURCE[0]}" "$@"
    exit 0
fi

#####################################################
#
#                   Parameters
#
#####################################################

# Base directory of the android sdk
ANDROID_HOME='/usr/local/lib/android'

#####################################################
#
#               Input processing
#
#####################################################

# Whether to force downloading the sdk tools
FORCE_DOWNLOAD='false'

while getopts 'f' OPTION; do
    case "$OPTION" in
        'f')
            FORCE_DOWNLOAD='true'
            ;;
        *)  # getopts has already printed an error message
            exit 1
            ;;
    esac
done
shift $(( OPTIND - 1 ))

# The hash at the end of the sdk zip on Google's website
SDK_ZIP_HASH="${1:-4333796}"

#####################################################
#
#   Android group and sdk home directory creation
#
#####################################################

mkdir -p "$ANDROID_HOME"

# Creating android user and group only if not already present
grep android /etc/group &> /dev/null || useradd -r -U android

#####################################################
#
#                   SDK download
#
#####################################################

SDK_ZIP_FILE='android-sdk-cli.zip'

# Skipping downloading of android sdk cli tools if they are already there,
# unless the download is forced
if [[ "$FORCE_DOWNLOAD" == 'true' || ! -d "$ANDROID_HOME/tools" ]]; then
    wget -O "$SDK_ZIP_FILE" \
        "https://dl.google.com/android/repository/sdk-tools-linux-${SDK_ZIP_HASH}.zip"
    unzip "$SDK_ZIP_FILE" -d "$ANDROID_HOME"
    rm "$SDK_ZIP_FILE"
fi

#####################################################
#
#   Making SDK available to the android group
#
#####################################################

# Users in the android group need to be able to write to the directory in
# order to use the sdk
chown -R android:android "$ANDROID_HOME"
chmod -R g+w "$ANDROID_HOME"

# Making all the executable in the android sdk available on PATH and
# executable by the group
find "$ANDROID_HOME" -type f -executable -not -name '*.*' \
    | while read FILE; do
        chmod g+x "$FILE"
        ln -sf "$FILE" /usr/local/bin
    done
