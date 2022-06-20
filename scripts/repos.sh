#!/usr/bin/env sh

# This script clones and initializes the coding workspace

########################################
# Install myrepos
########################################

case "$DISTRO" in
    'arch')
        yay -S --needed myrepos
        ;;

    'debian')
        apt-get install myrepos
        ;;
esac

########################################
# Install configuration files
########################################

printf '\e[32m[INFO]\e[0m Install mrconfig and myrepo libs\n'
dotdrop install -p repos -U both

########################################
# Clone and initialize
########################################

printf '\e[32m[INFO]\e[0m Clone coding workspace\n'
mr -d "$HOME" checkout

printf '\e[32m[INFO]\e[0m Initialize coding workspace\n'
mr -d "$HOME" init
