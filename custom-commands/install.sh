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
    C_SOURCE="$1"
    C_DEST_DIR="$2"

    C_EXEC_NAME="$(basename "$C_SOURCE" .c)"
    C_EXEC_PATH="${C_DEST_DIR:?}/$C_EXEC_NAME"

    gcc "$C_SOURCE" -o "$C_EXEC_PATH"
    chmod u+s "$C_EXEC_PATH"
    echo "$C_EXEC_NAME.c compiled and SUID bit set"

    unset C_DEST_DIR C_EXEC_NAME C_EXEC_PATH C_SOURCE
}

# This function copies a file in a destination directory, and makes it
# executable.
#
# Arguments
#   $1: Source file.
#   $2: Destination directory.
copy_file() {
    COPY_SOURCE="$1"
    COPY_DEST_DIR="$2"

    COPY_FILE_NAME="$(basename "$COPY_SOURCE")"
    COPY_DEST_FILE="${COPY_DEST_DIR:?}/$COPY_FILE_NAME"

    # --remove-destination is there to overwrite links used for development.
    cp --remove-destination "$COPY_SOURCE" "$COPY_DEST_FILE"
    chmod +x "$COPY_DEST_FILE"

    echo "$COPY_FILE_NAME copied"

    unset COPY_DEST_DIR COPY_DEST_FILE COPY_FILE_NAME COPY_SOURCE
}

# This function links a file in a destination directory, and makes it
# executable.
#
# Arguments
#   $1: Source file.
#   $2: Destination directory.
link_file() {
    LINK_SOURCE="$(readlink -f "$1")"
    LINK_DEST_DIR="$2"

    LINK_FILE_NAME="$(basename "$LINK_SOURCE")"

    ln -sf "$LINK_SOURCE" "${LINK_DEST_DIR:?}/$LINK_FILE_NAME"
    chmod +x "$LINK_SOURCE"
    echo "$LINK_FILE_NAME linked"

    unset LINK_DEST_DIR LINK_FILE_NAME LINK_SOURCE
}

# This function processes all the files in a directory, by passing them to
# process_file, using the same destination directory for all of them.
#
# Arguments:
#   - $1: The source directory.
#   - $2: The destination directory.
process_dir() {
    DIR_SOURCE="$1"
    DIR_DEST="$2"

    # -exec would not work since process_file is not in PATH
    find "$DIR_SOURCE" -maxdepth 1 -type f -o -type l \
        | process_file "$DIR_DEST"

    echo "Done with files in $DIR_SOURCE -> $DIR_DEST"

    unset DIR_SOURCE DIR_DEST
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
    FILE_DEST_DIR="$1"

    while read FILE_FILE; do
        case "$(file -b "$FILE_FILE" | tr '[:upper:]' '[:lower:]' \
                | cut -d ' ' -f 1)" in
            'c')
                compile_c "$FILE_FILE" "$FILE_DEST_DIR"
                ;;

            'bourne-again'|'python'|'posix'|'symbolic')
                publish_file "$FILE_FILE" "$FILE_DEST_DIR"
                ;;

            *)
                echo >&2 "$FILE_FILE is neither a C source, nor a bash/python " \
                    "script, neither a symbolic link"
                continue
                ;;
        esac
    done

    unset FILE_DEST_DIR FILE_FILE
}

#######################################
# Processing files
#######################################

# Files are given from the command line
if [ $# -gt 0 ]; then
    for FILE in "$@"; do
        FILE_PATH="$(find "$PARENT_DIR" -name "$FILE")"

        [ -z "$FILE_PATH" ] && {
            echo >&2 "$FILE not found!"
            continue
        }

        case "$FILE_PATH" in
            $USER_CMD_DIR/*)
                DEST_PATH="$USER_BIN_PATH"
                ;;

            $ROOT_CMD_DIR/*)
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
