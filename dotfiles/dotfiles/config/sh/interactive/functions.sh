#!/usr/bin/env sh

# This scripts defines some POSIX shell functions that are useful in
# interactive shells only

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
#   - $@: exa options to be added to the present ones, including the directory
#         to be listed. Optional.
l() {
    exa -abhls type --color=always --color-scale "$@" | less -FXR
}

# This is a convenience function for exa tree form. Other than calling exa with
# a bunch of nice options, it paginates the output if it doesn't fit in one
# screen, but without using a separate buffer.
#
# NOTE: It is not an alias since the parameter is not in last position.
#
# Arguments:
#   - $1: Tree levels to be displayed. Optional, defaults to 2.
#   - $2+: exa options to be added to the present ones, including the directory
#          to be listed. Optional. It includes the first argument when it's not
#          a number.
t() {
    T_LEVEL='2'
    echo "$1" | grep -E '[0-9]+' > /dev/null 2>&1 && {
        T_LEVEL="$1"
        shift
    }

    exa -abhlTs type --color=always --color-scale -L "$T_LEVEL" "$@" \
        | less -FXR

    unset T_LEVEL
}
