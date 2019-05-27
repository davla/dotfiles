#!/usr/bin/env sh

# This script initializes the POSIX shell cache.

#######################################
# Initializing $SDOTDIR
#######################################

mkdir -p "$SDOTDIR/cache"
mkdir -p "$SDOTDIR/plugins/data"

#######################################
# Initializing cache
#######################################

thefuck --alias > "$SDOTDIR/cache/thefuck"
fasd --init posix-alias > "$SDOTDIR/cache/fasd"
