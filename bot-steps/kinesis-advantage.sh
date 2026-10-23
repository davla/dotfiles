#!/usr/bin/env sh

# This script aids the installation of my custom key remaps on my Kinesis
# Advantage2 keyboard

# This doesn't work if this script is sourced
. "$(dirname "$0")/lib.sh"

########################################
# Functions
########################################

# This fuction returns the path to the Kinesis Advantage2 v-Drive
vdrive_path() {
    lsblk --json --nodeps --output PATH,VENDOR \
        | jq --raw-output '.blockdevices[] | select(.vendor == "Kinesis").path'
}

########################################
# Variables
########################################


print_info 'Mount Kinesis Advantage2 v-Drive'
VDRIVE_PATH="$(vdrive_path)"
while [ -z "$VDRIVE_PATH" ]; do
    echo 'Plug in the Kinesis Advantage2 v-Drive (Program + F1)...'
    print 'Press Enter when done... '
    # shellcheck disable=SC2034
    read -r ANSWER
    VDRIVE_PATH="$(vdrive_path)"
done
udisksctl mount --block-device "$VDRIVE_PATH"

print_info 'Copy custom qwerty layout key remappings'
dotdrop install -p keyboards

print_info 'Unmount Kinesis Advantage2 v-Drive'
udisksctl unmount --block-device "$VDRIVE_PATH"

echo 'Eject the Kinesis Advantage2 v-Drive (Program + F1)...'
print 'Press Enter when done... '
# shellcheck disable=SC2034
read -r ANSWER
