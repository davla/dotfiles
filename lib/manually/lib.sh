#!/usr/bin/env bash

# This function returns the initial part of the URL of a GitHub repository
# latest release.
#
# Argunemts:
#   - $1: The GitHub repository name
function _latest-github-release-url {
    local DOWNLOAD_URL="https://github.com/$1/releases/download"

    local LATEST_RELEASE
    LATEST_RELEASE="$(_latest-github-release "$1")"
    echo "$DOWNLOAD_URL/$LATEST_RELEASE"
}

function _latest-github-release {
    local RELEASES_URL="https://api.github.com/repos/$1/releases"
    wget -O - "$RELEASES_URL/latest" | jq -r '.tag_name'
}

function _latest-git-timestamp {
    local GIT_REPO="$1"

    local TMP_DIR
    TMP_DIR="$(mktemp -d)"

    git clone --depth 1 "$GIT_REPO" "$TMP_DIR"

    local GIT_TIMESTAMP
    GIT_TIMESTAMP="$(git show -s --format=%ct HEAD)"

    rm -rf "$TMP_DIR"

    echo "$GIT_TIMESTAMP"
}

function _latest-installed-timestamp {
    readlink -f "$1" | xargs -i stat -c '%Y' '{}'
}

# This functions compares two version numbers. It exits with a zero status code
# if the first version is newer than the second one, otherwise with a non-zero
# code: this occurs when the first version is equal or older than the second
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

function _is-newer-timestamp {
    [[ "$1" -lt "$2" ]]
}
