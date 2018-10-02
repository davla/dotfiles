#!/usr/bin/env bash

# This script serves the purpose of making some self-made bash scripts and C
# files available as CLI commands. This is achieved by creating symbolic links
# pointing to them in directories found in the PATH variable; this implies
# that even scripts that are run as root are editable as a non-privileged user,
# provided that they have the proper access rights.

# The bash scripts and C files are located in a directory under the stored
# files path. It is possible to link/compile all of them or just some, by
# providing their file name as CLI arguments.

# Aguments:
#   - $@: Names of bash scripts/C files to be linked/compiled.

#####################################################
#
#                   Variables
#
#####################################################

SCRIPTS_DIR="$(readlink -f 'Support/bin')"
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

# This function compiles a C file to an executable with the same name, but
# extension-less in the destination directory. The SUID bit is also set on the
# executable, since there are little reasons to use C other than accessing the
# low level Unix C API for root tasks.
#
# Arguments:
#   $1: C source file.
#   $2: Destination directory.
function compile-c {
    local SOURCE="$1"
    local DEST_DIR="$2"

    local EXEC_NAME
    EXEC_NAME=$(basename "$SOURCE" .c)
    local EXEC_PATH="$DEST_DIR/$EXEC_NAME"

    gcc "$SOURCE" -o "$EXEC_PATH"
    chmod u+s "$EXEC_PATH"
    echo "$EXEC_NAME.c compiled and SUID bit set"
}

# This function copies a symbolic link in a destination directory.
#
# Arguments
#   $1: Source file.
#   $2: Destination directory.
function copy-symlink {
    local SOURCE="$1"
    local DEST_DIR="$2"

    local FILE_NAME
    FILE_NAME="$(basename "$1")"

    cp "$FILE" "$DEST_DIR/$FILE_NAME"
    echo "$FILE_NAME copied"
}

# This function processes all the files in a directory, by passing them to
# process-file, using the same destination directory for all of them.
#
# Arguments:
#   - $1: The source directory.
#   - $2: The destination directory.
function process-dir {
    local SOURCE
    SOURCE="$(readlink -f "$1")"
    local DEST="$2"
    DEST="$(readlink -f "$2")"

    # -exec would not work since process-file is not in PATH
    find "$SOURCE" -maxdepth 1 -type f -o -type l | process-file "$DEST"

    echo "Done with files in $SOURCE -> $DEST"
}

# This filter processes files. This means that:
#     - they are compiled if they are C files
#     - they are linked if they are bash/python scripts
#     - they are copied if they are symbolic links
# The output of the processing is the same directory for all the files.
#
# Arguments:
#   - $1: The destination directory.
function process-file {
    local DEST_DIR
    DEST_DIR=$(readlink -f "$1")

    while read FILE; do
        case $(file -b "$FILE" | awk '{print tolower($1)}') in
            'c')
                compile-c "$FILE" "$DEST_DIR"
                ;;

            'bourne-again'|'python')
                symlink-script "$FILE" "$DEST_DIR"
                ;;

            'symbolic')
                copy-symlink "$FILE" "$DEST_DIR"
                ;;

            *)
                echo >&2 "$FILE is neither a C source, nor a bash/python " \
                    "script, neither a symbolic link"
                continue
                ;;
        esac
    done
}

# This function creates a symbolic link from the source file to a file with
# the same name in the destination directory. In order for this to work, it
# also needs to set the executable flag on the source file.
#
# Arguments
#   $1: Source file.
#   $2: Destination directory.
function symlink-script {
    local SOURCE="$1"
    local DEST_DIR="$2"

    local FILE_NAME
    FILE_NAME=$(basename "$SOURCE")

    chmod +x "$SOURCE"
    ln -sf "$SOURCE" "$DEST_DIR/$FILE_NAME"
    echo "$FILE_NAME linked"
}

#####################################################
#
#                   Privileges
#
#####################################################

# Checking for root privileges: if don't have them, recalling this script with
# sudo
if [[ $EUID -ne 0 ]]; then
    echo 'This script needs to be run as root'
    sudo bash "$0" "$@"
    exit 0
fi

#####################################################
#
#               Processing files
#
#####################################################

# Files are given from the command line
if [[ $# -gt 0 ]]; then
    for FILE in "$@"; do
        FILE_PATH=$(find "$SCRIPTS_DIR" -name "$FILE")

        if [[ "$FILE_PATH" == */$USER_SCRIPTS_SUBDIR/* ]]; then
            DEST_PATH="$USER_BIN_PATH"

        elif [[ "$FILE_PATH" == */$ROOT_SCRIPTS_SUBDIR/* ]]; then
            DEST_PATH="$ROOT_BIN_PATH"

        elif [[ -z "$FILE_PATH" ]]; then
            echo >&2 "$FILE not found!"
            continue

        else
            # Some other error, hopefully an error message has already been
            # printed
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
