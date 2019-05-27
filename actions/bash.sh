#!/usr/bin/env sh

# This script initializes bash cache.

#######################################
# Initializing $BDOTDIR
#######################################

mkdir -p "$BDOTDIR/cache"

#######################################
# Initializing cache
#######################################

fasd --init bash-hook bash-ccomp bash-ccomp-install > "$BDOTDIR/cache/fasd"
