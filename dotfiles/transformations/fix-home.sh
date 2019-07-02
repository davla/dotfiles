#!/usr/bin/env sh

# This scripts encodes a dotdrop transformation that fixes non-existing paths
# starting with $HOME or ~.

#######################################
# Input processing
#######################################

SRC_FILE="$1"
DST_FILE="$2"

#######################################
# Creating destination
#######################################

# -r since $SRC_FILE might be a directory
cp -r "$SRC_FILE" "$DST_FILE"

#######################################
# Handling directories
#######################################

[ -d "$SRC_FILE" ] && {

    # Recursively calling this script for every file in $SRC_DIR. In order to
    # correctly pair files in $SRC_DIR and $DST_DIR, %P is used, as it prints
    # the path relatively to $SRC_DIR, which is the same in $DST_DIR
    find "$SRC_FILE" -type f -printf '%P\n' \
        | xargs -i sh "$0" "$SRC_FILE/{}" "$DST_FILE/{}"
    exit
}

#######################################
# Fixing paths
#######################################

# This path grepping is very simplistic: no quoting, no spaces, no unicode
# support, and much more, but it works
for HOME_PATH in $(grep -oP '(~|\$HOME)/[\w\d_\-/]+' "$SRC_FILE"); do

    # Path relative to the home directory
    HOME_REL_PATH="$(echo "$HOME_PATH" | cut -d '/' -f 2-)"

    [ -e "$HOME/$HOME_REL_PATH" ] && continue

    # $HOME_REL_PATH is searched for in /home, not specifically in any user's
    # directory. -print -quit makes find stop after the fist match
    FOUND_PATH="$(find '/home' -path "*/$HOME_REL_PATH" -print -quit \
        2> /dev/null)"

    [ -n "$FOUND_PATH" ] && sed -i "s|$HOME_PATH|$FOUND_PATH|g" "$DST_FILE"
done
