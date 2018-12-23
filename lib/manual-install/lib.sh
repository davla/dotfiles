#!/usr/bin/env bash

# This file defines common utility functions for manual application
# installation machinery. These functions are mostly meant to be used in
# function definitions for single applications.

#####################################################
#
#                   Functions
#
#####################################################

# This function prints on STDOUT the initial part of the URL of a GitHub
# repository latest release.
#
# Argunemts:
#   - $1: The GitHub repository name
function _latest-github-release-url {
    local DOWNLOAD_URL="https://github.com/$1/releases/download"

    local LATEST_RELEASE
    LATEST_RELEASE="$(_latest-github-release "$1")"
    echo "$DOWNLOAD_URL/$LATEST_RELEASE"
}

# This function prints on STDOUT the latest release of a GitHub repository.
#
# Arguments:
#   - $1: The GitHub repository name
function _latest-github-release {
    local RELEASES_URL="https://api.github.com/repos/$1/releases"

    # Suppressing any output here in order not to pollute the intended output
    # of the function.
    wget -qO - "$RELEASES_URL/latest" | jq -r '.tag_name'
}

# This function writes on STDOUT the timestamp of the latest commit on master
# of a git repository.
#
# Arguments:
#   - $1: The git repository URL.
function _latest-git-timestamp {
    local GIT_REPO="$1"

    local TMP_DIR
    TMP_DIR="$(mktemp -d)"

    # Suppressing any output here in order not to pollute the intended output
    # of the function.
    git clone --depth 1 "$GIT_REPO" "$TMP_DIR" &> /dev/null

    local GIT_TIMESTAMP
    GIT_TIMESTAMP="$(git show -s --format=%ct HEAD)"

    rm -rf "$TMP_DIR"

    echo "$GIT_TIMESTAMP"
}

# This function writes on STDOUT the last edit timestamp of a local file.
#
# Arguments:
#   - $1: The local file.
function _latest-installed-timestamp {
    readlink -f "$1" | xargs stat -c '%Y'
}

# This function compares two version numbers. It exits with a zero status code
# if the first version is newer than the second one, otherwise with a non-zero
# code: this occurs when the first version is equal to or older than the second
# one.
#
# Arguments:
#     - $1: First version number.
#     - $2: Second version number.
function _is-newer-version-numbers {
    local FIRST="$1"
    local SECOND="$2"

    # Either the two versions are equal or sort -V will list the first version
    # last, so that the tail will be equal to it.
    [[ "$FIRST" != "$SECOND" && $(xargs -n 1 <<<"$FIRST $SECOND" \
        | sort -V | tail -n 1) == "$FIRST" ]]
}

# This function compares two timestamps. It exits with a zero status code if
# the first timestamp is more recent than the second one, otherwise with a
# non-zero status code: this occurs when the first timestamp is equal or
# smaller than the second one.
#
# Arguments:
#     - $1: First timestamp.
#     - $2: Second timestamp.
function _is-newer-timestamp {
    [[ "$1" -gt "$2" ]]
}
