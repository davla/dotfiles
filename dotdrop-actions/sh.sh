#!/usr/bin/env sh

# This script initializes the POSIX shell cache.

#######################################
# Initializing $SDOTDIR
#######################################

mkdir -p "$SDOTDIR/cache"

#######################################
# Initializing cache
#######################################

thefuck --alias > "$SDOTDIR/cache/thefuck"
