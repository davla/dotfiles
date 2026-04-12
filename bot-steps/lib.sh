#!/usr/bin/env sh

# This file contains utility code shared across bot steps

# This function installs a package via gh-release, ensuring the GitHub CLI is
# logged in.
#
# Arguments:
#   - $1: The package to be installed via gh-releases
gh_release_install() {
    ensure-gh-logged-in
    print_info "Install $1 via gh-release"
    sudo gh-release install "$1"
}

# This function installs my AUR helper of choice (yay).
#
# Arguments:
#   - $1: The unprivileged user to run the installation as.
#         Optional, defaults to $SUDO_USER.
install_aur_helper() (
    AUR_HELPER_USER="${1:-$SUDO_USER}"

    which yay > /dev/null 2>&1 && {
        print_info 'yay AUR helper already installed'
        return
    }

    print_info 'Install yay AUR helper'
    pacman --synchronize --refresh --refresh --needed git base-devel
    sudo --user "$AUR_HELPER_USER" sh -c '
        YAY_DIR="$(mktemp --directory XXX.yay.XXX)"
        trap "rm --recursive --force $YAY_DIR" EXIT HUP INT TERM

        git clone https://aur.archlinux.org/yay-bin.git "$YAY_DIR"
        cd "$YAY_DIR" || exit
        makepkg --syncdeps --install
        cd - > /dev/null 2>&1 || exit
    '
)

# Log the current user out if the DISPLAY_SERVER environment variable is *not*
# set to the given value.
# The idea is to properly initialize the graphical session by logging in again
# afterwards.
#
# Arguments:
#   - $1: The value the DISPLAY_SERVER environment variable should have in
#         order *not* to trigger a logout.
logout_into_graphical_session() {
    if [ "$DISPLAY_SERVER" != "$1" ]; then
        prompted_logout 'Logout necessary to load the graphical session'
    fi
}

# This function returns the absolute paths where the files belonging to a
# dotdrop profile are installed to.
#
# Arguments:
#   - $1: The dotdrop profile whose files will be returned
#   - $2: The user the dotdrop profile belongs to. Optional, defaults to "user"
dotdrop_files() (
    DOTDROP_PROFILE="$1"
    DOTDROP_USER="${2:-user}"

    dotdrop files -bGp "$DOTDROP_PROFILE" -U "$DOTDROP_USER" 2> /dev/null \
        | cut --delimiter ',' --fields 2 | cut --delimiter ':' --fields 2
)

# This function prints a line with an informative message, that is a string
# prefixed by a green "[INFO]"
#
# Arguments:
#   - n: don't print final newline.
#   - $1: the message to be printed.
print_info() (
    MSG="$1"
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

    printf "\e[32m[INFO]\e[0m %s$NEWLINE" "$MSG"
)

# Log out the current user upon pressing enter, after displaying an informative
# prompt.
#
# Arguments:
#   - $1: The informative prompt. Will be followed by '. Press enter...'.
prompted_logout() {
    echo "$1. Press enter..."
    # shellcheck disable=SC2034
    read -r ANSWER
    loginctl terminate-user "$USER"
}

# Configure the system package manager and flatpak and updates package lists.
#
# Arguments:
#   - $1: The unprivileged user to install the AUR helper as.
#         Optional, defaults to $SUDO_USER and then to $USER.
setup_package_managers() (
    AUR_HELPER_USER="${1:-${SUDO_USER:-$USER}}"
    case "$DISTRO" in
        'arch')
            print_info 'Setup pacman and yay'
            install_aur_helper "$AUR_HELPER_USER"
            dotdrop install -p packages -U root
            sudo --user "$AUR_HELPER_USER" yay --sync --refresh --refresh
            [ "$DISPLAY_SERVER" != 'headless' ] \
                && sudo --user "$AUR_HELPER_USER" \
                    yay --sync --needed flatpak
            ;;

        'debian')
            print_info 'Setup apt'
            dotdrop install -p packages -U root
            sudo apt-get update
            [ "$DISPLAY_SERVER" != 'headless' ] \
                && sudo apt-get install --no-install-recommends flatpak
            ;;
    esac
)
