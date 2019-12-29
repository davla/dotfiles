#!/usr/bin/env sh

# This script sets up the autorandr configuration. In particular:
#   - it creates some symbolic links to generic hook scripts for specific
#     configurations.
#   - it sets execution permission on hook scripts.
#
# Arguments:
#   - $1 - The directory where autorandr configurations are located.

#######################################
# Functions
#######################################

# This function creates symbolic links for autorandr hook scripts. In
# particular, it acts on the provided configurations, linking the preswitch
# hook to the provided script in scripts.d.
#
# Arguments:
#   - $1: The input autorandr configurations.
#   - $2: The script name in scripts.d.
#   - $3: The autorandr configuration directory.
link_hooks() {
    CONFIGS="$1"
    SCRIPT_NAME="$2"
    AUTORANDR_PATH="$3"

    for CONFIG in $CONFIGS; do
        ln -sf "$AUTORANDR_PATH/scripts.d/$SCRIPT_NAME" \
            "$AUTORANDR_PATH/$CONFIG/preswitch"
    done

    unset AUTORANDR_PATH CONFIGS TARGET_NAME
}

#######################################
# Variables
#######################################

# Lists of autorandr configuration names, split by dpi, based on host
case "$(hostname)" in
    'davide-laptop')
        HIDPI_CONFIGS=''
        LODPI_CONFIGS='hdmi-cph hdmi-fu dual-cph dual-fu'
        ;;

    *)
        HIDPI_CONFIGS=''
        LODPI_CONFIGS='hdmi dual'
        ;;
esac
HIDPI_CONFIGS="laptop-only $HIDPI_CONFIGS"

#######################################
# Input processing
#######################################

AUTORANDR_HOME="$(readlink -f "$1")"

#######################################
# Creating symbolic links
#######################################

# Configuration with HiDPI monitors
link_hooks "$HIDPI_CONFIGS" 'hidpi' "$AUTORANDR_HOME"

# Configuration with LoDPI monitors
link_hooks "$LODPI_CONFIGS" 'lodpi' "$AUTORANDR_HOME"

#######################################
# Setting executable permissions
#######################################

find "$AUTORANDR_HOME" -type f -regextype awk \
    -regex '.*/(predetect|preswitch|postsave|postswitch)' \
    -exec chmod +x '{}' \+
chmod +x "$AUTORANDR_HOME"/scripts.d/*
