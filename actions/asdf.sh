#!/usr/bin/env sh

# This script completes asdf plugin dotfiles installation
#
# Arguments:
#   - $1: The path to the asdf configuration directory.

#######################################
# Input processing
#######################################

ASDF_CONFIG="$(readlink -f "$1")"

#######################################
# Linking plugin dotfiles
#######################################

# Linking every file but "asdfrc" and "tool-versions", which are not asdf
# plugins configuration files.
#
# Fortunately, all plugins need their dotfiles straight in the home directory,
# so this can all be dealt with by a single command. Linking also adds a
# leading dot to the filename, as this is what the plugins require.
find "$ASDF_CONFIG" -mindepth 1 -type f -not -name 'asdfrc' \
        -not -name 'tool-versions' -printf '%f\0' \
    | xargs --null -i ln -sf "$ASDF_CONFIG/{}" "$HOME/.{}"
