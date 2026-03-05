#!/usr/bin/env sh

# This script installs packages not related to anything else on an Arch system,
# and performs some additional setup for some of them when required.
#
# Arguments:
#   - $1: user to run AUR helper with and for which rootless podman is set up.
#         Optional, defaults to $USER

# This doesn't work if this script is sourced
. "$(dirname "$0")/../../.dotfiles-env"
. "$(dirname "$0")/../lib.sh"

#######################################
# Input processing
#######################################

USER_NAME="${1:-$USER}"

#######################################
# Packages dotfiles
#######################################

print_info 'Install package manager dotfiles'
dotdrop install -p packages -U root

########################################
# Add additional repositories
########################################

# Chaotic AUR is x86_64-only
if [ "$MACHINE" != 'raspberry' ]; then
    # Chaotic AUR
    print_info 'Add Chaotic AUR repository'
    pacman-key --recv-key FBA220DFC880C036 --keyserver 'keyserver.ubuntu.com'
    pacman-key --lsign-key FBA220DFC880C036
    pacman -U --needed \
        'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' \
        'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
fi

#######################################
# Install AUR helper
#######################################

install_aur_helper "$USER_NAME"

#######################################
# Update package archive
#######################################

print_info 'Update package repository'
pacman -Suyy

#######################################
# Install GUI applications
#######################################

if [ "$DISPLAY_SERVER" != 'headless' ]; then
    case "$MACHINE" in
        'personal')
            print_info "Install GUI packages for $MACHINE"
            sudo --user "$USER_NAME" yay -S --needed alacritty blueman \
                firefox-beta-bin flatpak gnome-disk-utility gufw remmina \
                retroarch retroarch-assets-xmb visual-studio-code-insiders-bin
            # This doesn't work if this script is sourced
            sh "$(dirname "$0")/../flatpak.sh"
            ;;
    esac

    # No Bitwarden as it still has copy-paste issues on Wayland
    print_info 'Install GUI packages shared across all machines'
    sudo --user "$USER_NAME" yay -S --needed bitwarden-bin

    # Dotfiles
    print_info 'Install GUI packages dotfiles'
    sudo --user "$USER_NAME" dotdrop install -p gui
fi

#######################################
# Install CLI applications
#######################################

case "$MACHINE" in
    'personal')
        print_info "Install CLI packages for $MACHINE"
        sudo --user "$USER_NAME" yay -S --needed cups cups-pdf \
            docker-credential-secretservice-bin dropbox libretro nordvpn \
            rustup zsa-keymapp-bin
        ;;

    'raspberry')
        print_info "Install CLI packages for $MACHINE"
        sudo --user "$USER_NAME" yay -S --needed at certbot ddclient libjpeg
        ;;
esac

if [ "$MACHINE" != 'raspberry' ]; then
    print_info 'Install CLI packages for non-arm machines'
    sudo --user "$USER_NAME" yay -S --needed 7zip gdb ghc gifsicle \
        gnome-keyring hunspell hunspell-da hunspell-en_us hunspell-es_es \
        hunspell-it intel-ucode libsecret macchina networkmanager \
        polkit-gnome rar reflector shellcheck temp-throttle
        # dhcpcd doesn't work well with networkmanager (unless configured)
        if sudo --user "$USER_NAME" yay -Qs dhcpcd; then
            sudo --user "$USER_NAME" yay -R dhcpcd
        fi
fi

print_info 'Install CLI packages shared across all machines'
sudo --user "$USER_NAME" yay -S --needed autoconf automake bat bind cmake \
    cmatrix cowsay curl debugedit devbox-bin dkms dos2unix eza fasd \
    fortune-mod fzf gcc git-secret gnupg htop jq lua luacheck luarocks man \
    mercurial mmv moreutils multi-git-status myrepos nfs-utils nyancat \
    otf-ipafont pacman-contrib passt pkgfile playerctl podman-compose \
    podman-docker python python-pip rbw sheldon sl sudo thefuck ttf-baekmuk \
    ttf-dejavu ttf-indic-otf ttf-khmer ttf-nerd-fonts-symbols \
    ttf-nerd-fonts-symbols-mono unzip uv vim wqy-microhei-lite zip

# Dotfiles
print_info 'Install CLI packages dotfiles'
sudo --user "$USER_NAME" dotdrop install -p cli -U both

#######################################
# Upgrade
#######################################

print_info 'Upgrade system'
sudo --user "$USER_NAME" yay -Syyu

#######################################
# Initial setup
#######################################

# Rootless podman
print_info "Allow $USER_NAME to run rootless podman"
id "$USER_NAME" \
    | sed --regexp-extended 's/uid=([0-9]+).+ gid=([0-9]+).+/\1 \2/' \
    | {
        # Use shell group here because the variables created by read are only
        # available in the subshell created by the pipe
        read -r USER_ID GROUP_ID

        SUB_UID_START="$(( USER_ID + 99000 ))"
        usermod --add-subuids "$SUB_UID_START-$(( SUB_UID_START + 65535 ))" \
            "$USER_NAME"

        SUB_GID_START="$(( GROUP_ID + 99000 ))"
        usermod --add-subgids "$SUB_GID_START-$(( SUB_GID_START + 65535 ))" \
            "$USER_NAME"
    }
podman system migrate

# Dropbox
if [ "$MACHINE" = 'personal' ]; then
    # Prevent Dropbox auto-update by making its directory in $HOME read-only.
    # Adapted from
    # https://wiki.archlinux.org/title/dropbox#Prevent_automatic_updates.
    sudo --user "$USER_NAME" sh -c '\
        rm --recursive --force "$HOME/.dropbox-dist"; \
        install --directory --mode 000 "$HOME/.dropbox-dist"
    '

    print_info 'Enable and start dropbox and display device link URL'
    systemctl enable --now "dropbox@$USER_NAME"
    journalctl --boot --unit "dropbox@$USER_NAME" --output cat \
        --grep 'Please visit' | head --lines 1

    printf 'Press enter when authenticated...'
    # read requires a variable in POSIX shell
    # shellcheck disable=SC2034
    read -r ANSWER
    unset ANSWER

    # NordVPN
    print_info 'Configure NordVPN'
    usermod --append --groups nordvpn "$USER_NAME"
    sudo --user "$USER_NAME" nordvpn-config
fi
