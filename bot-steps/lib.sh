#!/usr/bin/env sh

# This file contains utility code shared across bot steps

# This function prints a line with an informative message, that is a string
# prefixed by a green "[INFO]"
#
# Arguments:
#   - n: don't print final newline.
#   - $1: the message to be printed.
print_info() {
    NEWLINE='\n'
    while getopts ':n' OPTION; do
        case "$OPTION" in
            'n')
                NEWLINE=''
                ;;

            *)
                echo >&2 "print_info: unknown flag: $OPTION"
                exit 63
                ;;
        esac
    done
    shift $(( OPTIND - 1 ))

    printf "\e[32m[INFO]\e[0m %s$NEWLINE" "$1"
    unset NEWLINE OPTION
}

# This function installs a package via gh-release but only if the GitHub CLI is
# already authenticated.
#
# Arguments:
#   - $1: The package to be installed via gh-releases
gh_release_install() {
    GH_RELEASE_INSTALL__PACKAGE="$1"

    gh auth status --active > /dev/null 2>&1 || {
        print_info -n "GitHub CLI not authenticated. Can't install "
        echo "$GH_RELEASE_INSTALL__PACKAGE via gh-releases"
        exit 0
    }

    print_info "Install $GH_RELEASE_INSTALL__PACKAGE via gh-release"
    sudo gh-release install "$GH_RELEASE_INSTALL__PACKAGE"

    unset GH_RELEASE_INSTALL__PACKAGE
}
