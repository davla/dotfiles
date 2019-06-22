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
ll() {
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
#   - $2: Tree levels to be displayed. Optional, defaults to 2. It can be
#         passed as first argument when using its default value.
#   - $3+: exa options to be added to the present ones. Optional. It includes
#          the second argument if the first one's not an existing path.
t() {
    if [ -e "$1" ]; then
        T_DIR="$1"
        T_LEVEL="${2:-2}"
        shift 2
    else
        T_DIR="$PWD"
        T_LEVEL="${1:-2}"
        shift
    fi

    exa -abhlTL "$T_LEVEL" --color=always --color-scale -s type "$T_DIR" "$@" \
        | less -FXR

    unset T_DIR T_LEVEL
}
