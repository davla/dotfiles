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

print_info 'Install myrepos-managed packages'
mr -d /opt -c /opt/.mrconfig checkout
mr -d /opt -c /opt/.mrconfig install

########################################
# GitHub releases-based installation
########################################

print_info 'Install github-releases'
dotdrop -U root install -p github-releases
sudo gh-release install
