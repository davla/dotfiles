#!/usr/bin/env sh

# This script sets up the network configuration, namely:
#   - A GNOME-network-manager script that disables Wi-Fi when cabled connection
#     is available, for hosts that have both network interfaces
#   - Local hosts to /etc/hosts
#   - Frequently visited host IP caching in /etc/hosts setup

# This doesn't work if this script is sourced
. "$(dirname "$0")/../.dotfiles-env"
. "$(dirname "$0")/lib.sh"

#######################################
# Install network manager
#######################################

if [ "$HOST" != 'raspberry' ]; then
    print_info 'Install GNOME network manager'
    case "$DISTRO" in
        'arch')
            pacman -S --needed networkmanager
            ;;

        'debian')
            apt-get install network-manager-gnome
            ;;
    esac
fi

#######################################
# Install dotfiles
#######################################

print_info 'Install network configuration'
dotdrop install -p network

#######################################
# Add frequently visisted hosts
#######################################

print_info 'Add frequently visited hosts'
host-refresh --info --journald off --color on

#######################################
# Apply changes
#######################################

if [ "$HOST" = 'raspberry' ]; then
    print_info 'Restart network daemon. This might impact the SSH connection.'
    systemctl restart systemd-networkd
fi
