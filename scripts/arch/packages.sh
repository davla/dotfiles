#!/usr/bin/env sh

# This script installs packages not related to anything else on an Arch system,
# and performs some additional setup for some of them when required.
#
# Arguments:
#   - $1: user to run AUR helper with

# This doesn't work if this script is sourced
. "$(dirname "$0")/../lib.sh"

#######################################
# Input processing
#######################################

USER="${1:-$USER}"

#######################################
# Packages dotfiles
#######################################

print_info 'Install package manager dotfiles'
dotdrop install -p packages -U root

########################################
# Add additional repositories
########################################

# Chaotic AUR is x86_64-only
if [ "$HOST" != 'raspberry' ]; then
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

if pacman -Q --quiet --search yay > /dev/null 2>&1; then
    print_info 'AUR helper already installed'
else
    print_info 'Install AUR helper'
    pacman -S --needed git base-devel

    YAY_DIR="$(sudo -u "$USER" mktemp --directory 'XXX.yay.XXX')"
    sudo -u "$USER" git clone 'https://aur.archlinux.org/yay-bin.git' \
        "$YAY_DIR"

    cd "$YAY_DIR" || exit
    sudo -u "$USER" makepkg -si
    cd - > /dev/null 2>&1 || exit

    sudo -u "$USER" rm -rf "$YAY_DIR"
fi

#######################################
# Update package archive
#######################################

print_info 'Update package repository'
pacman -Syy

#######################################
# Install GUI applications
#######################################

if [ "$DISPLAY_SERVER" != 'headless' ]; then
    case "$HOST" in
        'personal')
            print_info "Install GUI packages for $HOST"
            sudo -u "$USER" yay -S --needed alacritty asunder atril baobab \
                bitwarden blueman brasero calibre caprine firefox-beta-bin \
                geany gnome-disk-utility gnome-keyring gufw handbrake kid3 \
                libreoffice-still mpv remmina seahorse simple-scan \
                soundconverter spotify telegram-desktop thunderbird \
                transmission-gtk whatsapp-nativefier

            # Yay fails with a mysterious "-fork/exec" error when installing
            # visual-studio-code-insiders-bin from AUR *together* with other
            # packages.
            sudo -u "$USER" yay -S --needed aur/visual-studio-code-insiders-bin
            ;;
    esac

    # Dotfiles
    print_info 'Install GUI packages dotfiles'
    sudo -u "$USER" dotdrop install -p gui
fi

#######################################
# Install CLI applications
#######################################

case "$HOST" in
    'personal')
        print_info "Install CLI packages for $HOST"
        sudo -u "$USER" yay -S --needed cups cups-pdf dropbox rustup \
            zsa-wally-cli
        ;;

    'raspberry')
        print_info "Install CLI packages for $HOST"
        sudo -u "$USER" yay -S --needed at certbot ddclient libjpeg
        ;;
esac

if [ "$HOST" != 'raspberry' ]; then
    print_info 'Install CLI packages for non-arm hosts'
    sudo -u "$USER" yay -S --needed docker docker-compose \
        docker-credential-secretservice-bin gifsicle gdb ghc intel-ucode \
        libsecret hunspell hunspell-da hunspell-en_US hunspell-it \
        macchina-bin networkmanager polkit-gnome rar reflector shellcheck \
        temp-throttle-git
        # dhcpcd doesn't work well with networkmanager (unless configured)
        if sudo -u "$USER" yay -Qs dhcpcd; then
            sudo -u "$USER" yay -R dhcpcd
        fi
fi

print_info 'Install CLI packages shared across all hosts'
sudo -u "$USER" yay -S --needed antibody-bin asdf-vm autoconf automake bind \
    cmake cmatrix cowsay curl debugedit dkms dos2unix eza fasd fortune-mod \
    gcc git-secret gnupg htop jq lua luacheck man mercurial mmv moreutils \
    multi-git-status myrepos nfs-utils nyancat otf-ipafont pacman-contrib \
    p7zip pkgfile python python-pip python-pipenv sl sudo thefuck ttf-baekmuk \
    ttf-dejavu ttf-indic-otf ttf-khmer ttf-nerd-fonts-symbols \
    ttf-nerd-fonts-symbols-mono unzip vim wqy-microhei-lite zip

# Dotfiles
print_info 'Install CLI packages dotfiles'
sudo -u "$USER" dotdrop install -p cli -U both

#######################################
# Upgrade
#######################################

print_info 'Upgrade system'
sudo -u "$USER" yay -Syyu

#######################################
# Initial setup
#######################################

# Docker
if [ "$HOST" != 'raspberry' ]; then
    print_info "Add $USER to docker group"
    usermod -aG docker "$USER"
fi

# Dropbox
if [ "$HOST" = 'personal' ]; then
    # Prevent Dropbox auto-update by making its directory in $HOME read-only.
    # Adapted from
    # https://wiki.archlinux.org/title/dropbox#Prevent_automatic_updates.
    sudo -u "$USER" sh -c '\
        rm --recursive --force "$HOME/.dropbox-dist"; \
        install --directory --mode 000 "$HOME/.dropbox-dist"
    '

    print_info 'Enable and start dropbox and display device link URL'
    systemctl enable --now "dropbox@$USER"
    journalctl --boot --unit "dropbox@$USER" --output cat \
        --grep 'Please visit' | head -n 1

    printf 'Press enter when authenticated...'
    # read requires a variable in POSIX shell
    # shellcheck disable=SC2034
    read -r ANSWER
    unset ANSWER
fi
