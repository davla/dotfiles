#!/usr/bin/env sh

# This script installs manually managed packages and applications and performs
# their initial setup. Non self-updating applications are managed via myrepos,
# while the others have a custom installation process.
#
# Some machines/distros cause this script to exit early, as there's nothing to
# be manually installed

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
[ "$MACHINE" = 'raspberry' ] && {
    print_info 'Nothing to install manually via myrepos on raspberry'
    exit 0
}

#######################################
# Myrepos-based installation
#######################################

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

ensure-gh-logged-in

print_info 'Install gh-release'
dotdrop -U root install -p gh-release
gh-release install

########################################
# Miscellanea manual installation
########################################

if [ "$MACHINE" = 'work' ] && ! sudo which sentinelctl > /dev/null; then
    echo 'Download the SentinelOne .deb installer at https://sites.google.com/visma.com/sentineloneonboarding/install/linux'
    printf 'Enter the path to the SentinelOne .deb installer: '
    read -r SENTINEL_ONE_DEB

    dpkg --install "$SENTINEL_ONE_DEB"
    ln --symbolic --force /opt/sentinelone/bin/sentinelctl /usr/local/bin/sentinelctl
    sentinelctl management type set desktop

    printf 'Enter SentinelOne token from Notion (https://app.notion.com/p/penneo/SentinelOne-1e6f494fa41580c59ef5f1776ff58008#1e6f494fa41580aab08cdc76c5fff3f6): '
    read -r SENTINEL_ONE_TOKEN
    sentinelctl management token set "$SENTINEL_ONE_TOKEN"
    sentinelctl control start
fi
