#!/usr/bin/env sh

# This script downloads Android SDK command line tools, unless they are already
# on the filesystem, and makes the binaries available on $PATH to all users in
# the android group.

# Arguments:
#   - -f: Flag. When set, forces the download of the sdk tools.
#   - -b <base>: The base directory where the Android tools will be installed.
#       Defaults to /usr/local/lib/android.
#   - $1: name of the user to be added to the android group. Defaults to $USER
#         variable.
#   - $2: hash of the android sdk tools zip. Default to the latest one at the
#       time of writing (the same for over one year), that is 4333796.

#######################################
# Input processing
#######################################

# Base directory of the android sdk
ANDROID_HOME='/usr/local/lib/android'

# Whether to force downloading the sdk tools
FORCE_DOWNLOAD='false'

while getopts 'b:f' OPTION; do
    case "$OPTION" in
        'b')
            ANDROID_HOME="$OPTARG"
            ;;

        'f')
            FORCE_DOWNLOAD='true'
            ;;

        *)  # getopts has already printed an error message
            exit 1
            ;;
    esac
done
shift $(( OPTIND - 1 ))

USER_NAME="${1:-$USER}"
# The hash at the end of the sdk zip on Google's website
SDK_ZIP_HASH="${2:-4333796}"

#######################################
# Setting up Android environment
#######################################

mkdir -p "$ANDROID_HOME"

groupadd -f android
getent passwd android > /dev/null 2>&1 || useradd -r -g android android
usermod -aG android "$USER_NAME"
# Setting android user login group to android, even if the user is not created
# above
usermod -g android android

#######################################
# SDK download
#######################################

SDK_ZIP_FILE="$(mktemp)"

# Skipping downloading of android sdk cli tools if they are already there,
# unless the download is forced
if [ "$FORCE_DOWNLOAD" = 'true' ] || [ ! -d "$ANDROID_HOME/tools" ]; then
    wget -O "$SDK_ZIP_FILE" "https://dl.google.com/android/repository/\
sdk-tools-linux-${SDK_ZIP_HASH}.zip"
    unzip "$SDK_ZIP_FILE" -d "$ANDROID_HOME"
    rm "$SDK_ZIP_FILE"
fi

#######################################
# Making SDK available to android group
#######################################

# Users in the android group need to be able to write to the directory in
# order to use the sdk
chown -R android:android "$ANDROID_HOME"
chmod -R g+w "$ANDROID_HOME"

# Making all the executable in the android sdk available on PATH and
# executable by the group
find "$ANDROID_HOME" -type f -executable -not -name '*.*' \
    | while read -r FILE; do
        chmod g+x "$FILE"
        ln -sf "$FILE" /usr/local/bin
    done
