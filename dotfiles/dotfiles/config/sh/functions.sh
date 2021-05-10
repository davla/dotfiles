#!/usr/bin/env sh

# This scripts defines some POSIX shell functions, used in bot interactive and
# non-interactive shells

{%@@ if user == 'user' -@@%}

########################################
# Login functions
########################################

# This function starts the graphical session of my choice, only if executed on
# tty1 and if another instance of the same session is not already running.
start_graphical_session() {
    # So far I only start sway this way. Let's not overengineer it, then.
    [ "$TTY" = /dev/tty1 ] && [ -z "$WAYLAND_DISPLAY" ] && {
        systemd-cat --identifier=sway --stderr-priority=err sway
    }
}

{%@@ endif -@@%}

########################################
# Utility functions
########################################

# This function adds to PATH the local asdf-managed executables specified for
# the project in the current working directory
local_asdf_in_path() {
    echo 'Looking for local asdf executables'

    # Skipping python because virtualenvs make this redundant (and not working)
    LOCAL_ASDF_FOUND="$(asdf current | grep -vE '(system|python)' \
        | cut -d ' ' -f 1)"
    [ -z "$LOCAL_ASDF_FOUND" ] && {
        echo 'No asdf local plugins found'
        return
    }
    echo "Found these local plugins: $LOCAL_ASDF_FOUND" | paste -s -d ' '

    echo 'Exporting local plugins in PATH'
    export PATH="$(echo "$LOCAL_ASDF_FOUND" | xargs -n 1 asdf which \
        | xargs -n 1 dirname | paste -s -d ':'):$PATH"

    unset LOCAL_ASDF_EXCLUDE LOCAL_ASDF_FOUND
}
