#!/usr/bin/env bash

# This script serves the purpose of making some self-made scripts
# and C files available as CLI commands. This is achieved by creating
# symbolic links pointing to them in directories found in the PATH
# variable; this implies that even scripts that are run as root are
# editable as a non-privileged user, provided that they have the
# proper access rights.

# The shellscripts and C files are located in a directory under the
# stored files path. It is possible to link/compile all of them or just
# some, by providing their file name as CLI arguments.

#####################################################
#
#                   Variables
#
#####################################################

SCRIPTS_DIR='Support/bin'
ROOT_SCRIPTS_SUBDIR='root'
USER_SCRIPTS_SUBDIR='user'
ROOT_SCRIPTS_DIR="$SCRIPTS_DIR/$ROOT_SCRIPTS_SUBDIR"
USER_SCRIPTS_DIR="$SCRIPTS_DIR/$USER_SCRIPTS_SUBDIR"

ROOT_BIN_PATH='/usr/local/sbin'
USER_BIN_PATH='/usr/local/bin'

#####################################################
#
#                   Functions
#
#####################################################

# This function compiles a C file to an executable with
# the same name, butextension-less in the destination
# directory. The SUID bit is also set on the executable,
# since there are little reasons to use C other than
# accessing the low level Unix C API for root tasks.
#
# Arguments
#   $1: C source file
#   $2: Destination directory
function compile-c {
    local SOURCE="$1"
    local DEST_DIR="$2"

    local EXEC_NAME=$(basename "$SOURCE" .c)
    local EXEC_PATH="$DEST_DIR/$EXEC_NAME"

    gcc "$SOURCE" -o "$EXEC_PATH"
    chmod u+s "$EXEC_PATH"
    echo "$EXEC_NAME.c compiled and SUID bit set"
}

# This function processes all the files in a directory,
# that is compiling C files and linking shellscripts,
# using the same destination directory for all of them.
#
# Arguments:
#   - $1: The source directory.
#   - $2: The destination directory.
function process-dir {
    local SOURCE="$1"
    local DEST="$2"

    find "$SOURCE" -maxdepth 1 -type f | process-file "$DEST"

    echo "Done with files in $SOURCE -> $DEST"
}

# This filter processes files, that is, they are compiled
# if they are C files, or they are linked if they are
# shellscripts, every one to the same destination directory.
#
# Arguments:
#   - $1: The destination directory.
function process-file {
    local DEST_DIR="$1"

    while read FILE; do

        # No && || pair, since compilations might exit
        # with error codes
        if [[ $(file -b "$FILE" | awk '{print $1}') == 'C' ]]; then
            compile-c "$FILE" "$DEST_DIR"
        else
            symlink-script "$FILE" "$DEST_DIR"
        fi
    done
}

# This function creates a symbolic link from the source
# file to a file with the same name in the destination
# directory. In order for this to work, it also needs
# to set the executable flag on the source file.
#
# Arguments
#   $1: Source file
#   $2: Destination directory
function symlink-script {
    local SOURCE=$(realpath "$1")
    local DEST_DIR=$(realpath "$2")

    local FILE_NAME=$(basename "$SOURCE")

    chmod +x "$SOURCE"
    ln -sf "$SOURCE" "$DEST_DIR/$FILE_NAME"
    echo "$FILE_NAME linked"
}

#####################################################
#
#                   Privileges
#
#####################################################

# Checking for root privileges: if don't
# have them, recalling this script with sudo
if [[ $EUID -ne 0 ]]; then
    echo 'This script needs to be run as root'
    sudo bash $0 $@
fi

#####################################################
#
#               Processing files
#
#####################################################

# Files are given from the command line
if [[ $# -gt 0 ]]; then
    for FILE in $@; do
        FILE_PATH=$(find "$SCRIPTS_DIR" -name "$FILE")

        if [[ "$FILE_PATH" == */$USER_SCRIPTS_SUBDIR/* ]]; then
            DEST_PATH="$USER_BIN_PATH"

        elif [[ "$FILE_PATH" == */$ROOT_SCRIPTS_SUBDIR/* ]]; then
            DEST_PATH="$ROOT_BIN_PATH"

        elif [[ -z "$FILE_PATH" ]]; then
            echo >&2 "$FILE not found!"
            continue

        else
            # Some other error, hopefully an error message
            # hasalready been printed
            continue
        fi

        process-file "$DEST_PATH" <<<"$FILE_PATH"
    done

# All script in store are processed
else

    # Root
    [[ -d "$ROOT_SCRIPTS_DIR" ]] \
        && process-dir "$ROOT_SCRIPTS_DIR" "$ROOT_BIN_PATH" \
        || echo >&2 "$ROOT_SCRIPTS_DIR is not a directory: skipping root " \
            'executables'

    # User
    [[ -d "$USER_SCRIPTS_DIR" ]] \
        && process-dir "$USER_SCRIPTS_DIR" "$USER_BIN_PATH" \
        || echo >&2 "$USER_SCRIPTS_DIR is not a directory: skipping user " \
            'executables'
fi
