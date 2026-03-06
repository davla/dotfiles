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

# This function installs my AUR helper of choice (yay).
#
# Arguments:
#   - $1: The unprivileged user to run the installation as.
#         Optional, defaults to $SUDO_USER.
install_aur_helper() {
    INST_AUR_HELP__USER="${1:-$SUDO_USER}"

    which yay > /dev/null 2>&1 && {
        print_info 'yay AUR helper already installed'
        return
    }

    print_info 'Install yay AUR helper'
    pacman --synchronize --refresh --refresh --needed git base-devel
    sudo --user "$INST_AUR_HELP__USER" sh -c '
        YAY_DIR="$(mktemp --directory XXX.yay.XXX)"
        trap "rm --recursive --force $YAY_DIR" EXIT HUP INT TERM

        git clone https://aur.archlinux.org/yay-bin.git "$YAY_DIR"
        cd "$YAY_DIR" || exit
        makepkg --syncdeps --install
        cd - > /dev/null 2>&1 || exit
    '

    unset INST_AUR_HELP__USER
}

# Configure the system package manager and flatpak and updates package lists.
#
# Arguments:
#   - $1: The unprivileged user to install the AUR helper as.
#         Optional, defaults to $SUDO_USER and then to $USER.
setup_package_managers() {
    SETUP_PACK_MAN__USER="${1:-${SUDO_USER:-$USER}}"
    case "$DISTRO" in
        'arch')
            print_info 'Setup pacman and yay'
            install_aur_helper "$SETUP_PACK_MAN__USER"
            dotdrop install -p packages -U root
            sudo --user "$SETUP_PACK_MAN__USER" yay --sync --refresh --refresh
            [ "$DISPLAY_SERVER" != 'headless' ] \
                && sudo --user "$SETUP_PACK_MAN__USER" \
                    yay --sync --needed flatpak
            ;;

        'debian')
            print_info 'Setup apt'
            dotdrop install -p packages -U root
            apt-get update
            [ "$DISPLAY_SERVER" != 'headless' ] && apt-get install flatpak
            ;;
    esac
    unset SETUP_PACK_MAN__USER
}
