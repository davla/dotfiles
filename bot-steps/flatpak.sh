#!/usr/bin/env sh

# This script installs Flatpak applications on any distro. It assumes Flatpak
# itself to be already installed, since the installation process is
# distro-specific.

# This doesn't work if this script is sourced
. "$(dirname "$0")/../.dotfiles-env"
. "$(dirname "$0")/lib.sh"

########################################
# Early-exit
########################################

[ "$DISPLAY_SERVER" = 'headless' ] && {
    print_info 'Flatpak is only used for GUI applications'
    exit 0
}

########################################
# Install applications
########################################

case "$MACHINE" in
    'personal')
        print_info "Install Flatpak applications for $MACHINE"
        flatpak install --noninteractive brasero calibre caprine discordapp \
            freedownloadmanager fr.handbrake.ghb kid3 transmissionbt \
            org.signal.Signal soundconverter soundjuicer org.telegram.desktop \
            thunderbird
        ;;

    'work')
        print_info "Install Flatpak applications for $MACHINE"
        flatpak install --noninteractive slack
        ;;
esac

print_info 'Install Flatpak applications shared across all machines'
# No Bitwarden as it still has copy-paste issues on Wayland
flatpak install --noninteractive adwaita-dark baobab org.gnome.clocks drawing \
    org.geany.Geany io.mpv.Mpv pwvucontrol seahorse simplescan spotify
