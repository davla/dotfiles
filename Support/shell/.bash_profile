#!/usr/bin/env bash

# Executed on startup

# Emptying some directories

EMPTY_DIR=(
    '.local/share/Trash' # Thrash
    '.cache/sessions' # Sesions Cache
    '.cache/mozilla/firefox/*' # Firefox cache 1.0
    '.mozilla/firefox/*/Cache' # Firefox cache 2.0
)

for DIR in "${EMPTY_DIR[@]}"; do
    rm -rf "${HOME:?}/$DIR"
done
