#!/usr/bin/env sh

# This script installs packages not related to anything else on an Arch system,
# and performs some additional setup for some of them when required.
#
# Arguments:
#   - $1: user to run AUR helper with

# This doesn't work if this script is sourced
. "$(dirname "$0")/../../.env"

#######################################
# Input processing
#######################################

USER="${1:-$USER}"

#######################################
# Updating package archive
#######################################

pacman -Syy

#######################################
# Installing AUR helper
#######################################

pacman -S binutils fakeroot gcc git make

YAY_DIR='yay'
sudo -u "$USER" git clone 'https://aur.archlinux.org/yay.git' "$YAY_DIR"

cd "$YAY_DIR" || exit
sudo -u "$USER" makepkg -si
cd - > /dev/null 2>&1 || exit

sudo -u "$USER" rm -rf "$YAY_DIR"

#######################################
# Installing GUI applications
#######################################

case "$HOST" in
    'personal')
        sudo -u "$USER" yay -S asunder atril baobab blueman brasero calibre \
            code-git dropbox electron-ozone firefox-beta-bin geany gimp \
            gnome-clocks gnome-keyring gparted gufw handbrake \
            libreoffice-still kid3 remmina seahorse simple-scan \
            soundconverter spotify telegram-desktop thunderbird \
            transmission-gtk vlc
            # balena-etcher-electron bitwarden
        ;;
esac

# Dotfiles
sudo -u "$USER" dotdrop install -p gui

#######################################
# Installing CLI applications
#######################################

case "$HOST" in
    'personal')
        sudo -u "$USER" yay -S cups cups-pdf dex docker docker-compose \
            docker-credential-secretservice gdb intel-ucode libsecret \
            hunspell hunspell-da hunspell-en_US hunspell-it pulseaudio \
            pulseaudio-alsa pulseaudio-bluetooth pulseaudio-jack
        ;;

    'raspberry')
        sudo -u "$USER" yay -S at certbot ddclient
        ;;
esac

sudo -u "$USER" yay -S antibody-bin apng2gif asdf-vm autoconf automake cmake \
    cowsay curl dkms dos2unix fortune-mod gcc ghc gifsicle git-secret \
    git-review gnupg jq lua man mercurial moreutils multi-git-status myrepos \
    nfs-utils nyancat otf-ipafont p7zip pkgfile python python-pip \
    python-pipenv sudo ttf-baekmuk ttf-dejavu ttf-indic-otf ttf-khmer unzip \
    vim wqy-microhei-lite zip
    # luacheck shellcheck rar unrar
    # wmctrl xdotool for wayland

# Dotfiles
sudo -u "$USER" dotdrop install -p cli -U both

#######################################
# Upgrade
#######################################

sudo -u "$USER" yay -Su

#######################################
# Initial setup
#######################################

# Cups (printer service)
case "$HOST" in
    'personal')
        systemctl enable --now cups.socket
        ;;
esac

# Daily pkgfile update
systemctl enable --now pkgfile-update.timer

# Docker non root access.
groupadd -f docker
usermod -aG docker "$USER"
