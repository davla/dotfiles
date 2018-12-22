#!/usr/bin/env bash

# This scripts sets up the machinery for manually installing and updating
# applications that aren't packages in a repository. It then uses such
# machinery immediately to install them.

# Every application should define the following functions:
#   - is-installed: Exits with 0 if the application is installed,
#       non-zero otherwise.
#   - install: Installs the application.
#   - installed-version: Prints the installed version on STDOUT.
#   - latest-version: Prints the latest available version on STDOUT.
#   - is-newer <v1> <v2>: Exits with 0 if v1 equal or newer than v2, non-zero
#       otherwise.
#   - remove: Removes the application.
#
# Such functions should be defined inside *.inst files, located in the
# directory functions.d under the machinery installation path.

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
#               Manual installations
#
#####################################################

bash "$PARENT_DIR/custom-commands.sh" manual-install
manual-install
