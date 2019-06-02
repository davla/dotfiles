#!/usr/bin/env sh

#######################################
# Functions
#######################################

# Removes unwanted packages
clean() {
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
    apt-get purge -y xfce4-notes
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
    apt-get purge -y vim-common
    apt-get purge -y wbar
    apt-get purge -y wine
    apt-get purge -y xboard
    apt-get purge -y xchat-common
    apt-get purge -y xfburn
}

#######################################
# Privileges
#######################################

# Checking for root privileges: if don't have them, recalling this script with
# sudo
[ "$(id -u)" -ne 0 ] && {
    echo 'This script needs to be run as root'
    sudo sh "$0" "$@"
    exit
}

#######################################
# Repositoy keys
#######################################

# 379CE192D401AB61 --> Etcher
# C6ABDCF64DB9A0B2 --> Slack
# 931FF8E79F0876134EDDBDCCA87FF9DF48BF1C90 --> Spotify
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys '379CE192D401AB61' \
    'C6ABDCF64DB9A0B2' '931FF8E79F0876134EDDBDCCA87FF9DF48BF1C90' \
    | apt-key add -
wget -qO - 'https://packagecloud.io/AtomEditor/atom/gpgkey' | apt-key add -
apt-key adv --keyserver pgp.mit.edu --recv-keys 5044912E | apt-key add -
wget -qO - 'https://download.docker.com/linux/debian/gpg' | apt-key add -
wget -qO - 'https://dl.sinew.in/keys/enpass-linux.key' | apt-key add -
wget -qO - 'https://cli-assets.heroku.com/apt/release.key' | apt-key add -
wget -qO - 'https://repo.skype.com/data/SKYPE-GPG-KEY' | apt-key add -
wget -qO - 'https://www.virtualbox.org/download/oracle_vbox_2016.asc' | \
    apt-key add -
wget -qO - 'https://dl.yarnpkg.com/debian/pubkey.gpg' | apt-key add -
apt-get update -oAcquire::AllowInsecureRepositories=true
apt-get install -oAcquire::AllowInsecureRepositories=true \
    deb-multimedia-keyring

#######################################
# Drivers
#######################################

apt-get install firmware-realtek firmware-iwlwifi

#######################################
# Packages
#######################################

# GUI applications
apt-get install aisleriot asunder atom baobab blueman brasero calibre \
    camorama catfish dropbox enpass etcher evince firefox galculator gdebi \
    geany gimp gnome-mines gnome-sudoku gparted gufw handbrake-gtk \
    libreoffice-calc libreoffice-impress libreoffice-writer lightdm \
    lightdm-gtk-greeter-settings gnome-mahjongg hardinfo kid3 \
    network-manager-gnome parcellite pavucontrol quadrapassel \
    recordmydesktop gtk-recordmydesktop remmina sakura seahorse simple-scan \
    slack-desktop skypeforlinux solaar soundconverter spotify-client \
    synaptic system-config-printer thunderbird transmission-gtk tuxguitar \
    viewnior virtualbox visualboyadvance vlc
[ $? -ne 0 ] && exit

# CLI applications
apt-get install apng2gif autoconf automake build-essential cabal cmake \
    command-not-found cowsay cups curl dkms docker-ce dos2unix \
    flashplayer-mozilla fonts-freefont-otf fortune g++ ghc gifsicle git \
    git-review gvfs-backends handbrake-cli heroku hlint hunspell \
    hunspell-en-us hunspell-it imagemagick intel-microcode jq lame \
    libghc-hspec-dev libgit2-dev libgnome-keyring-dev lightdm-gtk-greeter lua \
    lua-check make mercurial moreutils nfs-common nyancat browser-plugin-vlc \
    p7zip pycodestyle python-requests-futures python-pip python-setuptools \
    python3-gdbm python3-lxml python3-pygments python3-requests \
    python3-requests-oauthlib rar sct shellcheck software-properties-common \
    sudo thunar-archive-plugin thunar-dropbox-plugin tree tuxguitar-jsa \
    uni2ascii unrar wmctrl xdotool xserver-xorg-input-synaptics yad zip
[ $? -ne 0 ] && exit

# --no-install-recommends prevents node from being installed
apt-get install --no-install-recommends yarn
[ $? -ne 0 ] && exit

# Xfce plugins
apt-get install xfce4-battery-plugin xfce4-cpugraph-plugin xfce4-eyes-plugin \
    xfce4-mailwatch-plugin xfce4-power-manager xfce4-screenshooter \
    xfce4-sensors-plugin xfce4-taskmanager xfce4-terminal
[ $? -ne 0 ] && exit

#######################################
# Clean & upgrade
#######################################

clean
apt-get update
apt-get upgrade

#######################################
# Packages setup
#######################################

# Docker non root access
grep docker /etc/group > /dev/null 2>&1 || groupadd docker

# Git credential helper
ln -s /usr/share/doc/git/contrib/credential/gnome-keyring/git-credential-gnome-keyring \
    /usr/bin/git-credential-gnome-keyring

# Gnome Keyring on startup
make -C /usr/share/doc/git/contrib/credential/gnome-keyring
sed -r -i 's/OnlyShowIn=/OnlyShowIn=XFCE;/' \
    /etc/xdg/autostart/gnome-keyring-pkcs11.desktop

# Sensor plugin
chmod u+s /usr/sbin/hddtemp
