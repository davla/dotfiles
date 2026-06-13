#!/usr/bin/env sh

# This script installs i3 customization dependencies

# This doesn't work if this script is sourced
. "$(dirname "$0")/../../.dotfiles-env"
. "$(dirname "$0")/../../bot-steps/lib.sh"

#######################################
# i3 config dependencies
#######################################

print_info 'Install dependencies used in the i3 config file'
case "$DISTRO" in
    'arch')
        yay -S --needed i3blocks i3-volume
        ;;

    'debian')
        sudo apt-get install --no-install-recommends i3blocks
        # Use absolute path because `dotdrop` resolves to the python package
        # binary within `uv run`
        /usr/local/bin/dotdrop install -U root -p manual
        gh_release_install i3-volume
        ;;
esac

#######################################
# i3 blocks dependencies
#######################################

print_info 'Install dependencies used in i3blocks scripts'
case "$DISTRO" in
    'arch')
        yay -S --needed bash i3blocks-contrib-git gnome-keyring python-keyring
        ;;

    'debian')
        sudo apt-get install --no-install-recommends aptitude bash \
            gnome-keyring python3-keyring
        sudo mr --directory /opt/i3blocks-contrib --config /opt/.mrconfig \
            checkout
        sudo mr --directory /opt/i3blocks-contrib --config /opt/.mrconfig \
            install
        ;;
esac
