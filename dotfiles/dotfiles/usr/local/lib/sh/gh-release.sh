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
# Variables
########################################

BASH_COMPLETIONS_DIR='/usr/local/share/bash-completion/completions'
ZSH_COMPLETIONS_DIR='/usr/local/share/zsh/site-functions'

########################################
# Functions
########################################

# This function outputs the current machine's CPU architechture name, such as
# "x86_64" or "arm64".
#
# Arguments:
#   - $1: One of 'x86_64' or 'amd64'. Controls what's output for the x86-64
#         architechture. Optional, defaults to 'x86_64'
cpu_arch() (
    FORMAT="${1:-x86_64}"

    case "$(echo "$FORMAT" | tr '[:upper:]' '[:lower:]')" in
        'x86_64')
            uname --machine
            ;;

        'amd64')
            uname --machine | sed 's/x86_64/amd64/'
            ;;

        *)
            echo >&2 "Unknown output format: $FORMAT"
            ;;
    esac
)

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
install_github_release_tar() (
    GITHUB_REPO="$1"
    RELEASE_TAG="$2"
    ARCHIVE_GLOB="$3"
    BIN_GLOB="${4:-*}"
    DST_DIR="${5:-/usr/local/bin}"

    COMPRESS=''
    case "$ARCHIVE_GLOB" in
        *.tar.gz)
            COMPRESS='--gzip'
            ;;

        *.tar.bz2)
            COMPRESS='--bzip2'
            ;;

        *.tar.xz)
            COMPRESS='--xz'
            ;;
    esac

    PACKAGE_NAME="${GITHUB_REPO##*/}"
    printf 'Download and install %s to %s...\n' "$PACKAGE_NAME" "$DST_DIR" \
        | log_debug
    printf 'Use %s to extract %s\n' "$COMPRESS" "$PACKAGE_NAME" | log_debug

    # The --transform option to tar extracts the basename
    gh --repo "$GITHUB_REPO" release download "$RELEASE_TAG" --output - \
            --pattern "$ARCHIVE_GLOB" \
        | tar --extract "$COMPRESS" --transform 's|.*/||g' \
            --directory "$DST_DIR" --wildcards "$BIN_GLOB"
)

# This function downloads and installs a .deb file from the assets of a GitHub
# release.
#
# Arguments:
#   - $1: The GitHub repository that made the release
#   - $2: The GitHub release tag
#   - $3: A glob matching the .deb release artifact by name
install_github_release_deb() (
    GITHUB_REPO="$1"
    RELEASE_TAG="$2"
    DEB_GLOB="$3"

    PACKAGE_NAME="${GITHUB_REPO##*/}"
    TMP_DEB="$(mktemp --dry-run "XXX-$PACKAGE_NAME.deb")"
    # shellcheck disable=SC2064
    trap "cleanup_trap $TMP_DEB" EXIT INT HUP TERM

    log_debug "Download $PACKAGE_NAME..."
    gh --repo "$GITHUB_REPO" release download "$RELEASE_TAG" \
        --output "$TMP_DEB" --pattern "$DEB_GLOB"

    log_debug "Install $PACKAGE_NAME..."
    dpkg --install "$TMP_DEB" | log_debug
)

# This function installs a bash completion file received via STDIN.
#
# Inputs:
#   - STDIN: The content of the bash completion.
#   - $1: The name for the completion file. If it's a path, only the base name
#         is used.
install_bash_completion() (
    COMPLETION_FILE="$(basename "$1")"

    log_info "Install bash completion for $COMPLETION_FILE"
    mkdir --parents "$BASH_COMPLETIONS_DIR"
    COMPLETION_PATH="$BASH_COMPLETIONS_DIR/$COMPLETION_FILE"
    log_debug "Write bash completion at $COMPLETION_PATH"
    cat > "$COMPLETION_PATH"
)

# This function installs a zsh completion file received via STDIN.
#
# Inputs:
#   - STDIN: The content of the zsh completion.
#   - $1: The name for the completion file. If it's a path, only the base name
#         is used. An '_' prefix is added if not already present.
install_zsh_completion() {
    COMPLETION_FILE="$(basename "$1")"

    log_info "Install zsh completion for $COMPLETION_FILE"
    mkdir --parents "$ZSH_COMPLETIONS_DIR"
    COMPLETION_PATH="$ZSH_COMPLETIONS_DIR/_${COMPLETION_FILE##_}"
    log_debug "Write zsh completion at $COMPLETION_PATH"
    cat > "$COMPLETION_PATH"
}
