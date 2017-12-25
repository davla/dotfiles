#!/usr/bin/env bash

# This script serves the purpose of making some self-made scripts
# and C files available as CLI commands. This is achieved by creating
# symbolic links pointing to them in directories found in the PATH
# variable; this implies that even scripts that are run as root are
# editable as a non-priviledged user, provided that they have the
# proper access rights.

#####################################################
#
#                   Variables
#
#####################################################

ROOT_SCRIPTS_DIR=$(realpath Support/bin/root)
ROOT_BIN_PATH='/usr/local/sbin'

USER_SCRIPTS_DIR=$(realpath Support/bin/user)
USER_BIN_PATH='/usr/local/bin'

#####################################################
#
#                   Functions
#
#####################################################

# This function creates symbolic links from the source
# directory to the destination directory for every file
# with no extension. In order for this to work, it also
# needs to set the executable flag on the linked files.
#
# Arguments
#   $1: Source directory
#   $2: Destination directory
function symlink-scripts {
    local SOURCE_DIR=$(realpath "$1")
    local DEST_DIR=$(realpath "$2")

    for SHELLSCRIPT in $(find "$SOURCE_DIR" -maxdepth 1 -type f \
            -not -name "*\.*"); do
        local FILE_NAME=$(basename "$SHELLSCRIPT")

        chmod +x "$SHELLSCRIPT"
        ln -sf "$SHELLSCRIPT" "$DEST_DIR/$FILE_NAME"
        echo "$FILE_NAME linked"
    done
    echo "Done with shellscripts in $SOURCE_DIR -> $DEST_DIR"
}

# This function compiles C files from the source
# directory, saving the output in the destination
# directory. The SUID bit is also set on the output,
# since there are little reasons to use C other than
# accessing the low level Unix C API for root tasks.
#
# Arguments
#   $1: Source directory
#   $2: Destination directory
function compile-c {
    local SOURCE_DIR=$(realpath "$1")
    local DEST_DIR=$(realpath "$2")

    for C_FILE in $(find "$SOURCE_DIR" -maxdepth 1 -type f -name "*.c"); do
        local EXEC_NAME=$(basename "$C_FILE" .c)
        local EXEC_PATH="$DEST_DIR/$EXEC_NAME"

        gcc "$C_FILE" -o "$EXEC_PATH"
        chmod u+s "$EXEC_PATH"
        echo "$EXEC_NAME.c compiled and SUID bit set"
    done
    echo "Done with C files in $SOURCE_DIR -> $DEST_DIR"
}

#####################################################
#
#                   Priviledges
#
#####################################################

# Checking for root priviledges: if don't
# have them, recalling this script with sudo
if [[ $EUID -ne 0 ]]; then
    echo 'This script needs to be run as root'
    sudo bash $0 $@
fi

#####################################################
#
#               PATH availability
#
#####################################################

# Root
if [[ -d "$ROOT_SCRIPTS_DIR" ]]; then
    symlink-scripts "$ROOT_SCRIPTS_DIR" "$ROOT_BIN_PATH"
    compile-c "$ROOT_SCRIPTS_DIR" "$ROOT_BIN_PATH"
else
    echo "$ROOT_SCRIPTS_DIR is not a directory: skipping root executables"
fi

# User
if [[ -d "$USER_SCRIPTS_DIR" ]]; then
    symlink-scripts "$USER_SCRIPTS_DIR" "$USER_BIN_PATH"
    compile-c "$USER_SCRIPTS_DIR" "$USER_BIN_PATH"
else
    echo "$USER_SCRIPTS_DIR is not a directory: skipping user executables"
fi
