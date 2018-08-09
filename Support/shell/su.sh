#!/usr/bin/env bash

# su executable path, so as not to recompute it every time in the next shim
SU_EXEC=$(which su)

# Two extra keystrokes is too much. Shimming su with this function, that calls
# `su -` when `su` is called with no arguments, and passes everything down to
# `su` otherwise.
#
# Arguments:
#   - $@: whatever su can take
function su {
    [[ -z "$*" ]] && "$SU_EXEC" - || "$SU_EXEC" "$@"
}
