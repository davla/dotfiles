#!/usr/bin/env bash

# This scripts installs a customized version of the standard
# XFCE menu, including layout, directories and desktop files

#####################################################
#
#                   Functions
#
#####################################################

# This function copies stored files to their designated system
# location, ignoring those starting with an underscore.
#
# Arguments:
#   - $1: Extension of the files to be copied.
#   - $2: Parent directory where the stored files are located.
#   - $3: Parent directory in the system location path.
function copy-files {
    local EXT="$1"
    local SOURCE="$2"
    local DEST="$3"

    [[ -n "$EXT" ]] && EXT=".$EXT"

    local SOURCE_DIR="Support/menu/$SOURCE/"
    local DEST_DIR="$HOME/.local/share/$DEST"
    local SOURCE_FILES="[^_]*$EXT"

    if [[ -n $(find "$SOURCE_DIR" -maxdepth 1 -mindepth 1 \
            -name "$SOURCE_FILES" 2> /dev/null) ]]; then
        mkdir -p "$DEST_DIR"
        cp -r "$SOURCE_DIR"/$SOURCE_FILES "$DEST_DIR"
    fi
}

#####################################################
#
#                       Layout
#
#####################################################

MENU_DIR="$HOME/.config/menus"

mkdir -p "$MENU_DIR"
cp Support/menu/xfce-applications.menu "$MENU_DIR"
echo 'Layout set'

#####################################################
#
#                   Directories
#
#####################################################

copy-files 'directory' 'directories' 'desktop-directories'
echo 'Directories set'

#####################################################
#
#                   Dektops
#
#####################################################

copy-files 'desktop' 'dekstops' 'applications'
echo 'Desktops set'

#####################################################
#
#                   Icons
#
#####################################################

copy-files '' 'icons' 'icons'
echo 'Icons set'
