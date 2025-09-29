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

# This function outputs the current machine's CPU architechture name, such as
# "x86_64" or "arm64".
#
# Arguments:
#   - $1: One of 'x86_64' or 'amd64'. Controls what's output for the x86-64
#         architechture. Optional, defaults to 'x86_64'
cpu_arch() {
    CPU_ARCH__FORMAT="${1:-x86_64}"

    case "$(echo "$CPU_ARCH__FORMAT" | tr '[:upper:]' '[:lower:]')" in
        'x86_64')
            uname --machine
            ;;

        'amd64')
            uname --machine | sed 's/x86_64/amd64/'
            ;;

        *)
            echo >&2 "Unknown output format: $CPU_ARCH__FORMAT"
            ;;
    esac

    unset CPU_ARCH__FORMAT
}

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

# This function downloads a tar archive from the assets of a GitHub release and
# extracts its content into a directory, stripping any directories in the
# archive.
#
# Arguments:
#   - $1: The GitHub repository that made the release
#   - $2: The GitHub release tag
#   - $3: A glob matching the tar archive release artifact by name
#   - $4: A glob used to select the files extracted from the tar archive
#         Optional, defults to extracting all the files in the archive
#   - $5: The directory where the tar archive is extracted to. Optional,
#         defaults to `/usr/local/bin`
install_github_release_tar() {
    GH_RELEASE_TAR__REPO="$1"
    GH_RELEASE_TAR__TAG="$2"
    GH_RELEASE_TAR__ARCHIVE_GLOB="$3"
    GH_RELEASE_TAR__BIN_GLOB="${4:-*}"
    GH_RELEASE_TAR__DST_DIR="${5:-/usr/local/bin}"

    GH_RELEASE_TAR__COMPRESS=''
    case "$GH_RELEASE_TAR__ARCHIVE_GLOB" in
        *.tar.gz)
            GH_RELEASE_TAR__COMPRESS='--gzip'
            ;;

        *.tar.bz2)
            GH_RELEASE_TAR__COMPRESS='--bzip2'
            ;;

        *.tar.xz)
            GH_RELEASE_TAR__COMPRESS='--xz'
            ;;
    esac

    GH_RELEASE_TAR__PACKAGE="${GH_RELEASE_TAR__REPO##*/}"
    printf 'Download and install %s to %s...\n' "$GH_RELEASE_TAR__PACKAGE" \
        "$GH_RELEASE_TAR__DST_DIR" | log_debug
    printf 'Use %s to extract %s\n' "$GH_RELEASE_TAR__COMPRESS" \
        "$GH_RELEASE_TAR__PACKAGE" | log_debug

    # The --transform option to tar extracts the basename
    gh --repo "$GH_RELEASE_TAR__REPO" release download "$GH_RELEASE_TAR__TAG" \
            --output - --pattern "$GH_RELEASE_TAR__ARCHIVE_GLOB" \
        | tar --extract "$GH_RELEASE_TAR__COMPRESS" --transform 's|.*/||g' \
            --directory "$GH_RELEASE_TAR__DST_DIR" \
            --wildcards "$GH_RELEASE_TAR__BIN_GLOB"

    unset GH_RELEASE_TAR__ARCHIVE_GLOB GH_RELEASE_TAR__BIN_GLOB \
        GH_RELEASE_TAR__COMPRESS GH_RELEASE_TAR__DST_DIR \
        GH_RELEASE_TAR__REPO GH_RELEASE_TAR__TAG
}

# This function downloads and installs a .deb file from the assets of a GitHub
# release.
#
# Arguments:
#   - $1: The GitHub repository that made the release
#   - $2: The GitHub release tag
#   - $3: A glob matching the .deb release artifact by name
install_github_release_deb() {
    GH_RELEASE_DEB__REPO="$1"
    GH_RELEASE_DEB__TAG="$2"
    GH_RELEASE_DEB__GLOB="$3"

    GH_RELEASE_DEB__PACKAGE="${GH_RELEASE_DEB__REPO##*/}"
    GH_RELEASE_DEB__TMP_DEB="$(mktemp --dry-run \
        "XXX-$GH_RELEASE_DEB__PACKAGE.deb")"
    # shellcheck disable=SC2064
    trap "cleanup_trap $GH_RELEASE_DEB__TMP_DEB" EXIT INT HUP TERM

    log_debug "Download $GH_RELEASE_DEB__PACKAGE..."
    gh --repo "$GH_RELEASE_DEB__REPO" release download "$GH_RELEASE_DEB__TAG" \
        --output "$GH_RELEASE_DEB__TMP_DEB" --pattern "$GH_RELEASE_DEB__GLOB"

    log_debug "Install $GH_RELEASE_DEB__PACKAGE..."
    dpkg --install "$GH_RELEASE_DEB__TMP_DEB" | log_debug

    unset GH_RELEASE_DEB__GLOB GH_RELEASE_DEB__PACKAGE GH_RELEASE_DEB__REPO \
        GH_RELEASE_DEB__TAG GH_RELEASE_DEB__TMP_DEB
}
