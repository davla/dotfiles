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

case "$HOST" in
    'personal')
        print_info "Install Flatpak applications for $HOST"
        # No Bitwarden as it still has copy-paste issues on Wayland
        flatpak install --noninteractive calibre caprine discordapp \
            freedownloadmanager fr.handbrake.ghb kid3 transmissionbt \
            org.signal.Signal soundconverter soundjuicer org.telegram.desktop \
            thunderbird
        ;; # dropbox retroarch
esac

print_info 'Install Flatpak applications shared across all hosts'
# No Bitwarden as it still has copy-paste issues on Wayland
flatpak install --noninteractive adwaita-dark baobab drawing org.geany.Geany \
    io.mpv.Mpv pwvucontrol seahorse simplescan spotify
