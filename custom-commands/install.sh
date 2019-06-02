#!/usr/bin/env sh

# This script install the custom commands in directories found in the PATH
# variable; C files are actually not copied, but compiled to binaries directly
# placed in such directories.
#
# Files in the `user` directory will be available to non-root users, while
# files in the `root` directory will be available to root only.

# It is possible to copy/compile all the files or just some, by providing their
# names as CLI arguments.
#
# For development purposes, files can be linked rather than copied; this
# doesn't apply to C files, though, in that they need to be compiled anyway.
# This is only possible when specifying some files as CLi arguments: in other
# words, it is not possible to link all the files by default.

# Aguments:
#   - -L: flag, enables linking, instead of copying, of the passed files.
#   - $@: Names of bash scripts/C files to be copied/compiled.

#######################################
# Privileges
#######################################

# Checking for root privileges: if don't have them, recalling this script with
# sudo
[ "$(id -u)" -ne 0 ] && {
    echo 'This script needs to be run as root'
    sudo sh "$0" "$@"
    exit
}

#######################################
# Variables
#######################################

# Absolute path to this scrpt parent directory. Doesn't work if this script is
# sourced
PARENT_DIR="$(dirname "$0")"

# Directories where root and user commands are respectively
ROOT_CMD_DIR="$PARENT_DIR/root"
USER_CMD_DIR="$PARENT_DIR/user"

# Destination directories of root and user commands respectively
ROOT_BIN_PATH='/usr/local/sbin'
USER_BIN_PATH='/usr/local/bin'

#######################################
# Input processing
#######################################

# Whether the specified files should be linked, rather than copied.
MAKE_LINKS='false'

while getopts 'L' OPTION; do
    case "$OPTION" in
        'L')
            MAKE_LINKS='true'
            ;;

        *)  # getopts has already printed an error message
            exit 1
            ;;
    esac
done
shift $(( OPTIND - 1 ))

# Need to specify some files when linking is on.
[ "$MAKE_LINKS" = 'true' ] && [ $# -lt 1 ] && {
    echo >&2 'You need to specify some files with the -L option'
    exit 1
}

# Setting publish-file to be link-file when -L is passed, copy-file otherwise
if [ "$MAKE_LINKS" = 'true' ]; then
    alias publish_file='link_file'
else
    alias publish_file='copy_file'
fi

#######################################
# Functions
#######################################

# This function compiles a C file to an executable with the same name, but
# extension-less in the destination directory. The SUID bit is also set on the
# executable, since there are little reasons to use C other than accessing the
# low level Unix C API for root tasks.
#
# Arguments:
#   $1: C source file.
#   $2: Destination directory.
compile_c() {
    SOURCE="$1"
    DEST_DIR="$2"

    EXEC_NAME="$(basename "$SOURCE" .c)"
    EXEC_PATH="$DEST_DIR/$EXEC_NAME"

    gcc "$SOURCE" -o "$EXEC_PATH"
    chmod u+s "$EXEC_PATH"
    echo "$EXEC_NAME.c compiled and SUID bit set"

    unset DEST_DIR EXEC_NAME EXEC_PATH SOURCE
}

# This function copies a file in a destination directory, and makes it
# executable.
#
# Arguments
#   $1: Source file.
#   $2: Destination directory.
copy_file() {
    SOURCE="$1"
    DEST_DIR="$2"

    FILE_NAME="$(basename "$SOURCE")"
    DEST_FILE="$DEST_DIR/$FILE_NAME"

    # --remove-destination is there to overwrite links used for development.
    cp --remove-destination "$SOURCE" "$DEST_FILE"
    chmod +x "$DEST_FILE"

    echo "$FILE_NAME copied"

    unset DEST_DIR DEST_FILE FILE_NAME SOURCE
}

# This function links a file in a destination directory, and makes it
# executable.
#
# Arguments
#   $1: Source file.
#   $2: Destination directory.
link_file() {
    SOURCE="$(readlink -f "$1")"
    DEST_DIR="$2"

    FILE_NAME="$(basename "$SOURCE")"

    ln -sf "$SOURCE" "$DEST_DIR/$FILE_NAME"
    chmod +x "$SOURCE"
    echo "$FILE_NAME linked"

    unset DEST_DIR FILE_NAME SOURCE
}

# This function processes all the files in a directory, by passing them to
# process_file, using the same destination directory for all of them.
#
# Arguments:
#   - $1: The source directory.
#   - $2: The destination directory.
process_dir() {
    SOURCE="$1"
    DEST="$2"

    # -exec would not work since process_file is not in PATH
    find "$SOURCE" -maxdepth 1 -type f -o -type l | process_file "$DEST"

    echo "Done with files in $SOURCE -> $DEST"

    unset SOURCE DEST
}

# This filter processes files. This means that:
#     - they are compiled if they are C files.
#     - they are copied/linked if they are bash/python script or symbolic links.
#     - they are skipped if they are anything else.
# The output of the processing is the same directory for all the files.
#
# Arguments:
#   - $1: The destination directory.
process_file() {
    DEST_DIR="$1"

    while read FILE; do
        case "$(file -b "$FILE" | tr '[:upper:]' '[:lower:]' \
                | cut -d ' ' -f 1)" in
            'c')
                compile_c "$FILE" "$DEST_DIR"
                ;;

            'bourne-again'|'python'|'posix'|'symbolic')
                publish_file "$FILE" "$DEST_DIR"
                ;;

            *)
                echo >&2 "$FILE is neither a C source, nor a bash/python " \
                    "script, neither a symbolic link"
                continue
                ;;
        esac
    done

    unset DEST_DIR FILE
}

#######################################
# Processing files
#######################################

# Files are given from the command line
if [ $# -gt 0 ]; then
    for FILE in "$@"; do
        FILE_PATH="$(find . -name "$FILE")"

        [ -z "$FILE_PATH" ] && {
            echo >&2 "$FILE not found!"
            continue
        }

        case "$FILE_PATH" in
            */$USER_CMD_DIR/*)
                DEST_PATH="$USER_BIN_PATH"
                ;;

            */$ROOT_CMD_DIR/*)
                DEST_PATH="$ROOT_BIN_PATH"
                ;;

            *)
                # Some other error, hopefully an error message has already been
                # printed
                continue
                ;;
        esac

        echo "$FILE_PATH" | process_file "$DEST_PATH"
    done

# All script in store are processed
else

    # Root
    if [ -d "$ROOT_CMD_DIR" ]; then
        process_dir "$ROOT_CMD_DIR" "$ROOT_BIN_PATH"
    else
        echo >&2 "$ROOT_CMD_DIR is not a directory: skipping root executables"
    fi

    # User
    if [ -d "$USER_CMD_DIR" ]; then
        process_dir "$USER_CMD_DIR" "$USER_BIN_PATH"
    else
        echo >&2 "$USER_CMD_DIR is not a directory: skipping user executables"
    fi
fi
