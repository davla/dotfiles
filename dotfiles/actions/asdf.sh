#!/usr/bin/env sh

# This script completes asdf plugin dotfiles installation
#
# Arguments:
#   - $1: The path to the asdf configuration directory.

# This doesn't work if this script is sourced
. "$(dirname "$0")/../../scripts/lib.sh"

#######################################
# Input processing
#######################################

ASDF_CONFIG="$(readlink -f "$1")"

#######################################
# Link plugin dotfiles
#######################################

# Link every file but "asdfrc" and "tool-versions", which are not asdf
# configuration files for plugins, but rather for asdf itself.
#
# Fortunately, all plugins need their dotfiles straight in the home directory,
# so this can all be dealt with by a single command. Linking also adds a
# leading dot to the filename, as this is what the plugins require.
print_info 'Link asdf plugin configuration files'
find "$ASDF_CONFIG" -mindepth 1 -type f -not -name 'asdfrc' \
        -not -name 'tool-versions' -printf '%f\0' \
    | xargs --null -i ln -sf "$ASDF_CONFIG/{}" "$HOME/.{}"
