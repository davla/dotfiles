#!/usr/bin/env sh

# This scripts defines useful (or not) POSIX shell functions

#######################################
# Core commands functions
#######################################

# This is a convenience function for exa long form. Other than calling exa with
# a bunch of nice options, it paginates the output if it doesn't fit in one
# screen, but without using a separate buffer.
#
# NOTE: It is not an alias since the parameter is not in last position.
#
# Arguments:
#   - $1: The directory or file to be listed. Optional, defaults to the current
#         working directory.
#   - $2+: exa options to be added to the present ones. Optional. It includes
#          the first argument if it's not an existing path.
l() {
    if [ -e "$1" ]; then
        L_DIR="$1"
        shift
    else
        L_DIR="$PWD"
    fi

    exa -abhls type --color=always --color-scale "$L_DIR" "$@" | less -FXR

    unset L_DIR
}

# This is a convenience function for exa tree form. Other than calling exa with
# a bunch of nice options, it paginates the output if it doesn't fit in one
# screen, but without using a separate buffer.
#
# NOTE: It is not an alias since the parameter is not in last position.
#
# Arguments:
#   - $1: The directory or file to be listed. Optional, defaults to the current
#         working directory.
#   - $2: Tree levels to be displayed. Optional, defaults to 2. If the first
#         argument is omitted, this one can replace it.
#   - $3+: exa options to be added to the present ones. Optional. It includes
#          the first two arguments when they are omitted.
t() {
    if [ -e "$1" ]; then
        T_DIR="$1"
        shift
    else
        T_DIR="$PWD"
    fi

    # $1 as arguments are either shifted, or the file/directory is left out.
    if echo "$1" | grep -E '[0-9]+' > /dev/null 2>&1; then
        T_LEVEL="$1"
        shift
    else
        T_LEVEL='2'
    fi

    exa -abhlTs type --color=always --color-scale -L "$T_LEVEL" "$T_DIR" "$@" \
        | less -FXR

    unset T_DIR T_LEVEL T_SHIFT_OFFSET
}
