#!/usr/bin/env sh

# This scripts defines useful (or not) POSIX shell functions

#######################################
# Core commands functions
#######################################

# This is just a convenience alias for ls. It paginates the output if it
# doesn't fit in one screen, bit without using a separate buffer.
#
# NOTE: not an alias since the parameter is not in last position.
l() {
    ls -lAFh --color=always "${1:-$PWD}" | less -FXR
}
