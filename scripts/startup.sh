#!/usr/bin/env sh

# This script sets up the system startup, including both system and user
# startup jobs

# This doesn't work if this script is sourced
. "$(dirname "$0")/../.dotfiles-env"

#######################################
# Setting up system/user startup jobs
#######################################

dotdrop -U both install -p startup
