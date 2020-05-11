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
# Installing CLI applications
#######################################

sudo -u "$USER" yay -S antibody-bin apng2gif asdf-vm at autoconf automake certbot cmake cowsay \
    curl ddclient dex dkms dos2unix fortune-mod gcc gifsicle git-secret \
    git-review jq lua man mercurial moreutils nfs-utils nyancat p7zip pkgfile \
    python python-pip python-pipenv sudo unzip vim zip

# Dotfiles
sudo -u "$USER" dotdrop install -p cli -U both

#######################################
# Upgrade
#######################################

sudo -u "$USER" yay -Su

#######################################
# Initial setup
#######################################

systemctl enable --now pkgfile-update.timer
