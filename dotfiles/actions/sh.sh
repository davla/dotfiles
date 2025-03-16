#!/usr/bin/env sh

# This script initializes the POSIX shell dotfies setup.
#
# Arguments:
#   - $1: The file defining the POSIX shell configuration directory path.

# This doesn't work if this script is sourced
. "$(dirname "$0")/../../scripts/lib.sh"

#######################################
# Input processing
#######################################

DOTDIRS_FILE="${1:?}"

#######################################
# Load environment variables
#######################################

# This script needs the POSIX shell's environment variables to function
# correctly. However, they need to be loaded explicitly, because the dotfiles
# are indeed not fully set up yet, as this very script is meant to do so.

. "$DOTDIRS_FILE"
. "${SDOTDIR:?}/shenv"

#######################################
# Create symbolic links
#######################################

# POSIX shell has some non-configurable startup file paths, like
# $HOME/.profile. Here, symbolic links are created from those paths to the
# actual files in the bash configuration directory.
print_info 'Link POSIX shell startup files in home directory'
ln --force --symbolic --relative "${SDOTDIR:?}/profile" "$HOME/.profile"

#######################################
# Initialize cache
#######################################

sh "$SDOTDIR/interactive/write-cache.sh" --info --journald off
