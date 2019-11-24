#!/usr/bin/env sh

# This script sets up the autorandr configuration. In particular:
#   - it creates some symbolic links to generic hook scripts from specific
#     configurations
#   - it sets execution permission on hook scripts
#
# Arguments:
#   - $1 - The directory where autorandr configurations are located.

#######################################
# Functions
#######################################

# This function creates symbolic links for autorandr hook scripts. In
# particular, it acts on every configuration ending in a specific suffix
# (which is prepended a dash). For such configurations, the preswitch hook
# script is linked to the script in scripts.d named after the configuration
# suffix.
# As an example, the suffix "docked" would link the preswitch hook of the
# configuration "my-docked" to "scripts.d/docked"
#
# Arguments:
#   - $1: The configuration name suffix (and target script name).
#   - $2: The autorandr configuration directory.
link_hooks() {
    TARGET_NAME="$1"
    AUTORANDR_HOME="$2"

    find "$AUTORANDR_HOME" -type d -name "*-$TARGET_NAME" \
        -exec ln -sf "$AUTORANDR_HOME/scripts.d/$TARGET_NAME" '{}/preswitch' \;

    unset TARGET_NAME
}

#######################################
# Input processing
#######################################

AUTORANDR_HOME="$(readlink -f "$1")"

#######################################
# Creating symbolic links
#######################################

# Configuration with HiDPI monitors
link_hooks 'hidpi' "$AUTORANDR_HOME"

# Configuration with LoDPI monitors
link_hooks 'lodpi' "$AUTORANDR_HOME"

#######################################
# Setting executable permissions
#######################################

find "$AUTORANDR_HOME" -type f -regextype awk \
    -regex '.*/(predetect|preswitch|postsave|postswitch)' \
    -exec chmod +x '{}' \+
chmod +x "$AUTORANDR_HOME"/scripts.d/*
