#!/usr/bin/env sh

# This file contains shared utility functions for software management based on
# GitHub releases
#
# {{@@ header() @@}}

#######################################
# Libraries includes
#######################################

. "{{@@ logger_path @@}}"

########################################
# Functions
########################################

# This function removes its arguments. It is mean to be used as a script
# termination trap.
#
# Arguments:
#   - $@: Files and directories to be removed.
cleanup_trap() {
    log_debug "Remove $*"
    rm --force --recursive "$@"
    trap - EXIT
    exit
}

# This function extracts files from the sources artiface of a GitHub release.
# The sources assets' URL is extracted from the release assets metadata, which
# are input in JSON format.
#
# Arguments:
#   - $1: The file patterns to be extracted from the sources asset, relative
#         to the repository root.
#   - $2: The GitHub repository that made the release. Only used for logging
#   - $3: The directory the files from the sources assets are extracted.
#         Optional, defaults to the current directory
#   - STDIN: The GitHub release JSON metadata
download_from_source_tarball() {
    DL_SRC_TAR__FILE_PATTERN="$1"
    DL_SRC_TAR__GITHUB_REPO="$2"
    DL_SRC_TAR__OUT_DIR="${3:-.}"

    jq --raw-output '.tarball_url' \
        | {
            xargs wget --quiet --output-document - \
                || wget_error 'Failed to download sources asset for ' \
                    "$DL_SRC_TAR__GITHUB_REPO"
        } | tar --extract --gzip --no-anchored --strip-components 1 \
                --directory "$DL_SRC_TAR__OUT_DIR" \
                --wildcards "$DL_SRC_TAR__FILE_PATTERN"
}

# This function downloads an asset from a GitHub release. The asset's URL is
# extracted from the release metadata, which is input in JSON format.
#
# Arguments:
#   - $1: The jq filter used to extract the asset's URL. It is applied to the
#         "assets" array in the GitHub release JSON metadata
#   - $2: The GitHub repository that made the release. Only used for logging
#   - $3: The path the asset is downloaded to. Optional, defaults to STDOUT
#   - STDIN: The GitHub release JSON metadata
download_github_release_asset() {
    DL_GH_RELEASE_ASSET__JQ_FILTER="$1"
    DL_GH_RELEASE_ASSET__GITHUB_REPO="$2"
    DL_GH_RELEASE_ASSET__OUT="${3:--}"

    jq --raw-output ".assets[] | select($DL_GH_RELEASE_ASSET__JQ_FILTER).browser_download_url" \
        | {
            xargs wget --quiet --output-document "$DL_GH_RELEASE_ASSET__OUT" \
                || wget_error "Failed to download release for" \
                    "$DL_GH_RELEASE_ASSET__GITHUB_REPO with jq filter" \
                    "'$DL_GH_RELEASE_ASSET__JQ_FILTER'"
        }

    unset DL_GH_RELEASE_ASSET__GITHUB_REPO DL_GH_RELEASE_ASSET__JQ_FILTER \
        DL_GH_RELEASE_ASSET__OUT
}

# This function downloads and installs a .deb file from the assets of a GitHub
# release. The .deb's URL is extracted from the .name field of the release
# metadata, which is input in JSON format.
#
# Arguments:
#   - $1: The jq filter used to extract the asset's URL. It is applied to the
#         "assets[] | .name" array in the GitHub release JSON metadata
#   - $2: The GitHub repository that made the release. Only used for logging
#   - STDIN: The GitHub release JSON metadata
install_github_release_deb() {
    INSTALL_GH_RELEASE_DEB__NAME_JQ_FILTER="$1"
    INSTALL_GH_RELEASE_DEB__GITHUB_REPO="$2"

    INSTALL_GH_RELEASE_DEB__PACKAGE_NAME="${INSTALL_GH_RELEASE_DEB__GITHUB_REPO##*/}"
    INSTALL_GH_RELEASE_DEB__TMP_DEB_FILE="$(mktemp \
        "XXX-$INSTALL_GH_RELEASE_DEB__PACKAGE_NAME.deb")"
    # shellcheck disable=SC2064
    trap "cleanup_trap $INSTALL_GH_RELEASE_DEB__TMP_DEB_FILE" EXIT INT HUP TERM

    log_debug "Download $INSTALL_GH_RELEASE_DEB__PACKAGE_NAME..."
    download_github_release_asset \
        ".name | $INSTALL_GH_RELEASE_DEB__NAME_JQ_FILTER" \
        "$INSTALL_GH_RELEASE_DEB__GITHUB_REPO" \
        "$INSTALL_GH_RELEASE_DEB__TMP_DEB_FILE"

    log_debug "Install $INSTALL_GH_RELEASE_DEB__PACKAGE_NAME..."
    dpkg --install "$INSTALL_GH_RELEASE_DEB__TMP_DEB_FILE" | log_debug

    unset INSTALL_GH_RELEASE_DEB__GITHUB_REPO \
        INSTALL_GH_RELEASE_DEB__NAME_JQ_FILTER \
        INSTALL_GH_RELEASE_DEB__PACKAGE_NAME \
        INSTALL_GH_RELEASE_DEB__TMP_DEB_FILE
}

# This function logs the given arguments as an error and exits with the chosen
# error code for wget errors (67)
#
# Arguments:
#   - $@: The error log message
wget_error() {
    log_error "$*"
    exit 67
}
