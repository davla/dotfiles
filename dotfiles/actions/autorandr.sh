#!/usr/bin/env sh

# This script sets up the autorandr configuration. In particular:
#   - it creates some symbolic links to generic hook scripts for specific
#     configurations.
#
# Arguments:
#   - $1 - The directory where autorandr configurations are located.

# This doesn't work if this script is sourced
. "$(dirname "$0")/../../.dotfiles-env"
. "$(dirname "$0")/../../bot-steps/lib.sh"

#######################################
# Functions
#######################################

# This function creates symbolic links for autorandr hook scripts. In
# particular, it acts on the provided configurations, linking the preswitch
# hook to the provided script in scripts.d.
#
# Arguments:
#   - $1: The script name in scripts.d.
#   - $2: The autorandr configuration directory.
#   - stdin: The input autorandr configurations.
link_hooks() {
    SCRIPT_NAME="$1"
    AUTORANDR_PATH="$2"

    xargs -I '{}' ln --force --symbolic --relative \
        "$AUTORANDR_PATH/scripts.d/$SCRIPT_NAME" "$AUTORANDR_PATH/{}/preswitch"

    unset AUTORANDR_PATH CONFIGS TARGET_NAME
}

#######################################
# Variables
#######################################

# Lists of autorandr configuration names that need dpi-adjusting hook scripts.
# Split by host.
case "$HOST" in
    'personal')
        HIDPI_CONFIGS='laptop-only-personal'
        LODPI_CONFIGS=''
        ;;

    *)
        HIDPI_CONFIGS=''
        LODPI_CONFIGS=''
        ;;
esac

#######################################
# Input processing
#######################################

AUTORANDR_HOME="$(readlink -f "$1")"

#######################################
# Create symbolic links
#######################################

# Configuration with HiDPI monitors
print_info 'Link autorandr HiDPI hook scripts'
echo "$HIDPI_CONFIGS" | link_hooks 'hidpi' "$AUTORANDR_HOME"

# Configuration with LoDPI monitors
print_info 'Link autorandr LoDPI hook scripts'
echo "$LODPI_CONFIGS" | link_hooks 'lodpi' "$AUTORANDR_HOME"
