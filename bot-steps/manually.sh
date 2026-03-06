#!/usr/bin/env sh

# This script installs manually managed packages and applications and performs
# their initial setup. Non self-updating applications are managed via myrepos,
# while the others have a custom installation process.
#
# Some hosts/distros cause this script to exit early, as there's nothing to be
# manually installed

# This doesn't work if this script is sourced
. "$(dirname "$0")/../.dotfiles-env"
. "$(dirname "$0")/lib.sh"

########################################
# Early-exit
########################################

[ "$DISTRO" = 'arch' ] && {
    print_info -n 'Nothing to install manually via myrepos in Arch, we have '
    echo 'AUR :D'
    exit 0
}
[ "$HOST" = 'raspberry' ] && {
    print_info 'Nothing to install manually via myrepos on raspberry'
    exit 0
}

#######################################
# Myrepos-based installation
#######################################

print_info 'Install myrepos'
apt-get install myrepos

print_info 'Install myrepos package management dotfiles'
dotdrop install -p manual -U root

MRCONFIG='/opt/mrconfig'
[ -s "$MRCONFIG" ] && {
    MRDIR="$(dirname "$MRCONFIG")"
    print_info 'Install myrepos-managed packages'
    mr --directory "$MRDIR" --config "$MRCONFIG" checkout
    mr --directory "$MRDIR" --config "$MRCONFIG" install
}

########################################
# GitHub releases-based installation
########################################

[ "$DISPLAY_SERVER" = 'headless' ] && {
    print_info 'gh-release not installed. Need a browser for authentication'
    exit 0
}

print_info 'Authenticate GitHub CLI'
sudo --user "$USER_NAME" sh -c \
    'gh auth status --active > /dev/null 2>&1 || gh auth login --web'
sudo --user "$USER_NAME" gh auth token | gh auth login --with-token

print_info 'Install gh-release'
dotdrop -U root install -p gh-release
sudo gh-release install
