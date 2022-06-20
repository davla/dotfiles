#!/usr/bin/env sh

# This script installs packages not related to anything else on an Arch system,
# and performs some additional setup for some of them when required.
#
# Arguments:
#   - $1: user to run AUR helper with

#######################################
# Input processing
#######################################

USER="${1:-$USER}"

#######################################
# Packages dotfiles
#######################################

dotdrop install -p packages -U root

#######################################
# Updating package archive
#######################################

pacman -Syy

#######################################
# Installing AUR helper
#######################################

pacman -Qqs yay > /dev/null 2>&1 || {
    pacman -S --needed binutils fakeroot gcc git make

    YAY_DIR="$(mktemp -d 'XXX.yay.XXX')"
    sudo -u "$USER" git clone 'https://aur.archlinux.org/yay.git' "$YAY_DIR"

    cd "$YAY_DIR" || exit
    sudo -u "$USER" makepkg -si
    cd - > /dev/null 2>&1 || exit

    sudo -u "$USER" rm -rf "$YAY_DIR"
}

#######################################
# Installing GUI applications
#######################################

if [ "$DISPLAY_SERVER" != 'headless' ]; then
    case "$HOST" in
        'personal')
            sudo -u "$USER" yay -S --needed asunder atril baobab bitwarden \
                blueman brasero calibre electron firefox-beta-bin geany gimp \
                gnome-clocks gnome-disk-utility gnome-keyring gufw handbrake \
                libreoffice-still kid3 remmina seahorse simple-scan \
                soundconverter telegram-desktop thunderbird transmission-gtk \
                vlc-git visual-studio-code-bin
            ;;
    esac

    # Dotfiles
    sudo -u "$USER" dotdrop install -p gui
fi

#######################################
# Installing CLI applications
#######################################

case "$HOST" in
    'personal')
        sudo -u "$USER" yay -S --needed cups cups-pdf nordvpn zsa-wally-cli
        ;;

    'raspberry')
        sudo -u "$USER" yay -S --needed at certbot ddclient
        ;;
esac

if [ "$HOST" != 'raspberry' ]; then
    sudo -u "$USER" yay -S --needed apng2gif dex docker docker-compose \
        docker-credential-secretservice gifsicle gdb ghc intel-ucode \
        libsecret hunspell hunspell-da hunspell-en_US hunspell-it \
        macchina-bin networkmanager polkit-gnome temp-throttle-git
        # dhcpcd doesn't work well with networkmanager (unless configured)
        if sudo -u "$USER" yay -Qs dhcpcd; then
            sudo -u "$USER" yay -R dhcpcd
        fi
fi

sudo -u "$USER" yay -S --needed antibody-bin asdf-vm autoconf automake cmake \
    cowsay curl dkms dos2unix exa fasd fortune-mod gcc git-secret gnupg jq \
    lua man mercurial moreutils multi-git-status myrepos nfs-utils nyancat \
    otf-ipafont p7zip pkgfile python python-pip python-pipenv sudo thefuck \
    ttf-baekmuk ttf-dejavu ttf-indic-otf ttf-khmer unzip vim \
    wqy-microhei-lite zip
    # luacheck shellcheck rar unrar

# Dotfiles
sudo -u "$USER" dotdrop install -p cli -U both

#######################################
# Upgrade
#######################################

sudo -u "$USER" yay -Syyu

#######################################
# Initial setup
#######################################

# Docker
if [ "$HOST" != 'raspberry' ]; then
    usermod -aG docker "$USER"
fi

case "$HOST" in
    'personal')
        # NordVPN
        usermod -aG nordvpn "$USER"
        sudo -u "$USER" nordvpn-config
        ;;
esac
