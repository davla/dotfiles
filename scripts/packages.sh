#!/usr/bin/env sh

# This script installs packages not related to anything else on the system, and
# performs some additional setup for some of them when required.
#
# Arguments:
#   - $1: name of the user to be added to the docker group. Defaults to $USER
#         variable.

. ./.env

#######################################
# Variables
#######################################

# Executable file names to be linked on $PATH
EXECS='arduino
halt
mysql
php
reboot
Telegram'

# Directory in $PATH where executables are linked
PATH_DIR='/usr/local/bin'

#######################################
# Functions
#######################################

# This function removes unwanted packages
clean() {
    # Unsetting -e so that non-existing packages won't make the script exit
    echo "$-" | grep 'e' > /dev/null 2>&1 \
        && HAS_E='true' \
        || HAS_E='false'
    set +e

    apt-get purge -y abiword-common
    apt-get purge -y audacious
    apt-get purge -y ayatana-indicator-common
    apt-get purge -y calendar-google-provider
    apt-get purge -y conky-std
    apt-get purge -y xfce4-clipman
    apt-get purge -y xfce4-clipman-plugin
    apt-get purge -y disk-manager
    apt-get purge -y exaile
    apt-get purge -y exfalso
    apt-get purge -y fairymax
    apt-get purge -y firefox-esr
    apt-get purge -y geoclue-2.0
    apt-get purge -y gftp-common
    apt-get purge -y gnome-chess
    apt-get purge -y gnome-mplayer
    apt-get purge -y gnome-schedule
    apt-get purge -y gnome-user-guide
    apt-get purge -y gnote
    apt-get purge -y gnuchess
    apt-get purge -y gnuchess-book
    apt-get purge -y gpicview
    apt-get purge -y hexchat-common
    apt-get purge -y hexchat-perl
    apt-get purge -y hexchat-plugins
    apt-get purge -y hexchat-python
    apt-get purge -y hoichess
    apt-get purge -y htop
    apt-get purge -y iagno
    apt-get purge -y icedove
    apt-get purge -y iceowl-extension
    apt-get purge -y iceweasel
    apt-get purge -y leafpad
    apt-get purge -y libabiword-2.9
    apt-get purge -y libflorence-1.0-1
    apt-get purge -y liferea-data
    apt-get purge -y mc-data
    apt-get purge -y metacity
    apt-get purge -y minissdpd
    apt-get purge -y mutt
    apt-get purge -y nautilus
    apt-get purge -y oracle-java6-installer
    apt-get purge -y oracle-java6-set-default
    apt-get purge -y xfce4-notes
    apt-get purge -y pidgin-data
    apt-get purge -y plymouth
    apt-get purge -y python3-packagekit
    apt-get purge -y python-libturpial
    apt-get purge -y radiotray
    apt-get purge -y ristretto
    apt-get purge -y sambashare
    apt-get purge -y shotwell-common
    apt-get purge -y smtube
    apt-get purge -y tali
    apt-get purge -y terminator
    apt-get purge -y uget
    apt-get purge -y wbar
    apt-get purge -y wine
    apt-get purge -y xboard
    apt-get purge -y xchat-common
    apt-get purge -y xfburn

    [ "$HAS_E" = 'true' ] && set -e
    unset HAS_E
}

#######################################
# Input processing
#######################################

USER_NAME="${1:-$USER}"

#######################################
# Repositories dotfiles
#######################################

dotdrop --user root install -p packages

#######################################
# Installing Drivers
#######################################

apt-get install firmware-realtek firmware-iwlwifi

#######################################
# Installing GUI applications
#######################################

# Installation
apt-get install aisleriot asunder atom baobab blueman brasero calibre \
    camorama catfish dropbox enpass balena-etcher-electron evince \
    galculator gdebi geany gimp gnome-mines gnome-sudoku gparted gufw \
    handbrake-gtk libreoffice-calc libreoffice-impress libreoffice-writer \
    gnome-mahjongg hardinfo kid3 parcellite pavucontrol quadrapassel \
    recordmydesktop gtk-recordmydesktop remmina seahorse simple-scan \
    slack-desktop skypeforlinux solaar soundconverter spotify-client synaptic \
    system-config-printer thunderbird transmission-gtk tuxguitar viewnior \
    virtualbox visualboyadvance vlc

# Dotfiles
sudo -u "$USER_NAME" dotdrop install -p gui

#######################################
# Installing CLI applications
#######################################

# Installation
apt-get install apng2gif autoconf automake build-essential cabal-install \
    cmake command-not-found cowsay cups curl dkms docker-ce dos2unix \
    flashplayer-mozilla fonts-freefont-otf fortune g++ ghc gifsicle git \
    git-review gvfs-backends handbrake-cli heroku hlint hunspell \
    hunspell-en-us hunspell-it hub imagemagick intel-microcode jq lame \
    libghc-hspec-dev libgit2-dev libgnome-keyring-dev lua5.1 lua-check make \
    mercurial moreutils nfs-common nyancat p7zip pycodestyle \
    python-requests-futures python-pip python-setuptools python3-gdbm \
    python3-lxml python3-pygments python3-requests python3-requests-oauthlib \
    rar sct shellcheck software-properties-common thunar-archive-plugin \
    thunar-dropbox-plugin tuxguitar-jsa uni2ascii unrar wmctrl xdotool \
    xserver-xorg-input-synaptics yad zip

# --no-install-recommends prevents node from being installed
apt-get install --no-install-recommends yarn

# Dotfiles
sudo -u "$USER_NAME" dotdrop install -p cli

#######################################
# Clean & upgrade
#######################################

clean
apt-get update
apt-get upgrade

#######################################
# Packages setup
#######################################

# Docker non root access.
groupadd -f docker
usermod -g docker "$USER_NAME"

# Git credential helper
ln -sf /usr/share/doc/git/contrib/credential/gnome-keyring/\
git-credential-gnome-keyring /usr/bin/git-credential-gnome-keyring
make -C /usr/share/doc/git/contrib/credential/gnome-keyring

# Symlinking executables in a $PATH directory accessible to unpirvileged users
echo "$EXECS" | while read EXEC; do
    # Trying to find another executable with the same name in $PATH. If no
    # executable is found on $PATH, scanning the whole filesystem
    EXEC_PATH="$(
        (which -a "$EXEC" | grep -v 'not found' | grep -v "$PATH_DIR" \
            || find / -type f -executable -name "$EXEC" 2> /dev/null) \
        | head -n 1)"
    [ -z "$EXEC_PATH" ] && {
        echo >&2 "$EXEC not found"
        continue
    }

    # Only lowercase executables in $PATH
    echo "$EXEC" | tr '[:upper:]' '[:lower:]' \
        | xargs -i ln -sf "$EXEC_PATH" "$PATH_DIR/{}"

    # Setting SUID for root-owned executables
    [ "$(stat -c %U "$EXEC_PATH")" = 'root' ] && chmod u+s "$EXEC_PATH"

    echo "$EXEC linked"
done
