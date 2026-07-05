#!/usr/bin/env sh

# This script sets up the network configuration, namely:
#   - NetworkManager installation and configuration
#   - Local hosts to /etc/hosts
#   - Frequently visited host IP caching in /etc/hosts setup

# This doesn't work if this script is sourced
. "$(dirname "$0")/../.dotfiles-env"
. "$(dirname "$0")/lib.sh"

#######################################
# Install NetworkManager
#######################################

if [ "$MACHINE" != 'raspberry' ]; then
    print_info 'Install NetworkManager'
    case "$DISTRO" in
        'arch')
            pacman -S --needed networkmanager
            # dhcpcd doesn't work well with NetworkManager (unless configured)
            if pacman -Qs dhcpcd; then
                pacman -R dhcpcd
            fi
            ;;

        'debian')
            # ifupdown can't removed before installing NetworkManager, as that
            # would, obviously, cut the Internet connection.
            apt-get install --no-install-recommends network-manager \
                network-manager-tui systemd-resolved
            rm --force --recursive /etc/network/*
            # dhcpcd doesn't work well with NetworkManager (unless configured)
            apt-get purge ifupdown isc-dhcp-server
            ;;
    esac
fi

#######################################
# Install dotfiles
#######################################

print_info 'Install network configuration'
dotdrop install -p network

########################################
# Reboot if no DNS are available
########################################

resolvectl dns --json short \
    | jq --exit-status 'any(.servers != null)' > /dev/null || {
        echo 'Reboot necessary to load network configuration. Press enter...'
        # shellcheck disable=SC2034
        read -r ANSWER
        systemctl reboot
    }

#######################################
# Add frequently visisted hosts
#######################################

print_info 'Add frequently visited hosts'
host-refresh --info --journald off --color on
