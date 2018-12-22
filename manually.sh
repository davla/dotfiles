#!/usr/bin/env bash

# This scripts sets up the machinery for manually installing and updating
# applications that aren't packages in a repository. It then uses such
# machinery immediately to install them

#####################################################
#
#                   Variables
#
#####################################################

# Absolute path of this script's parent directory
PARENT_DIR="$(dirname "${BASH_SOURCE[0]}")"
MANUAL_LIB_DIR="$PARENT_DIR/lib/manual-install"

# Machinery directories
BASE_MANUAL_DIR='/usr/local/lib/manual-install'
MANUAL_FUNCTIONS_DIR="$BASE_MANUAL_DIR/functions.d"
MANUAL_LOG_DIR="$BASE_MANUAL_DIR/log"

#####################################################
#
#               Machinery setup
#
#####################################################

mkdir -p "$BASE_MANUAL_DIR" "$MANUAL_FUNCTIONS_DIR" "$MANUAL_LOG_DIR"

cp "$MANUAL_LIB_DIR/lib.sh" "$BASE_MANUAL_DIR"
cp "$MANUAL_LIB_DIR/"*.inst "$MANUAL_FUNCTIONS_DIR"

#####################################################
#
#           Manual installations
#
#####################################################

bash "$PARENT_DIR/custom-commands.sh" manual-install
manual-install
