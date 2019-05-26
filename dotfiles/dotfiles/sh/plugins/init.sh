#!/usr/bin/env sh

# This script configures and loads POSIX shell plugins and tools

#######################################
# asdf
#######################################

echo "$0" | grep -xP 'sh' || {
    export ASDF_PATH='/opt/asdf'
    export ASDF_CONFIG_DIR="$ASDF_PATH/etc"
    export ASDF_CONFIG_FILE="$ASDF_CONFIG_DIR/.asdfrc"
    export ASDF_DATA_DIR="$ASDF_PATH/data"
    export ASDF_DEFAULT_TOOL_VERSIONS_FILENAME=\
"$ASDF_CONFIG_DIR/.tool-versions"
    . "$ASDF_PATH/asdf.sh"
}

#######################################
# thefuck
#######################################

. "$SDOTDIR/cache/thefuck"
