#!/usr/bin/env sh

# This script clones and initializes the coding workspace

# This doesn't work if this script is sourced
. "$(dirname "$0")/lib.sh"

########################################
# Install myrepos
########################################

case "$DISTRO" in
    'arch')
        yay -S --needed myrepos
        ;;

    'debian')
        sudo apt-get install myrepos
        ;;
esac

########################################
# Install configuration files
########################################

print_info 'Install coding workspace dotfiles'
dotdrop install -p repos -U both

########################################
# Clone and initialize
########################################

print_info 'Clone coding workspace'
mr -d "$HOME" checkout

print_info 'Initialize coding workspace'
mr -d "$HOME" init
