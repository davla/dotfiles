#!/usr/bin/env bash

# This scripts installs my preferred applications and
# performs some initial setup for such applications

#####################################################
#
#                   Functions
#
#####################################################

# Removes applications coming preinstalled with distributions
function clean {
    apt-get purge -y abiword-common
    apt-get purge -y audacious
    apt-get purge -y ayatana-indicator-common
    apt-get purge -y calendar-google-provider
    apt-get purge -y conky-std
    apt-get purge -y xfce4-clipman
    apt-get purge -y xfce4-clipman-plugin
    apt-get purge -y disk-manager
    apt-get purge -y exaile
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
    apt-get purge -y sparky-xdf
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

#####################################################
#
#                   Privileges
#
#####################################################

# Checking for root privileges: if don't
# have them, recalling this script with sudo
if [[ $EUID -ne 0 ]]; then
    echo 'This script needs to be run as root'
    sudo bash "$0" "$@"
    exit 0
fi

#####################################################
#
#           APT Sources & Preferences
#
#####################################################

cp Support/apt/sources/* /etc/apt/sources.list.d
cp Support/apt/preferences/* /etc/apt/preferences.d
mv /etc/apt/sources.list.d/sources.list /etc/apt

#####################################################
#
#               Repository keys
#
#####################################################

# 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5 --> MongoDB
# EEA14886 --> Oracle Java installer
# E0F72778C4676186 --> Playonlinux
# 2EE0EA64E40A89B84B2DF73499E82A75642AC823 --> Scala sbt
# C6ABDCF64DB9A0B2 --> Slack
# EFDC8610341D9410 --> Spotify
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys \
    '2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5' 'EEA14886' 'E0F72778C4676186' \
    '2EE0EA64E40A89B84B2DF73499E82A75642AC823' 'C6ABDCF64DB9A0B2' \
    'EFDC8610341D9410' | apt-key add -
apt-key adv --keyserver pgp.mit.edu --recv-keys 5044912E | apt-key add -
wget -qO - 'https://www.virtualbox.org/download/oracle_vbox_2016.asc' | \
    apt-key add -
wget -qO - 'https://download.docker.com/linux/debian/gpg' | apt-key add -
wget -qO - 'https://repo.skype.com/data/SKYPE-GPG-KEY' | apt-key add -
wget -qO - 'https://debian.neo4j.org/neotechnology.gpg.key' | apt-key add -
wget -qO - 'https://dl.sinew.in/keys/enpass-linux.key' | apt-key add -
wget -qO - 'https://packagecloud.io/AtomEditor/atom/gpgkey' | apt-key add -
wget -qO - 'https://dl.yarnpkg.com/debian/pubkey.gpg' | apt-key add -
apt-get update
apt-get install deb-multimedia-keyring software-properties-common \
    sparky-keyring

#####################################################
#
#               Clean & upgrade
#
#####################################################

# Cleaning undesired packages,
# so that they won't be upgraded
clean

# Updating
apt-get update
apt-get upgrade

#####################################################
#
#           Installing applications
#
#####################################################

# GUI applications
apt-get install aisleriot asunder atom baobab blueman brasero calibre \
    camorama catfish dia dropbox enpass evince firefox five-or-more \
    galculator gdebi geany gimp gnome-klotski gnome-mines gnome-nibbles \
    gnome-sudoku gnome-robots gnome-tetravex gparted gufw handbrake-gtk \
    hitori libreoffice-calc libreoffice-impress libreoffice-writer lightdm \
    lightdm-gtk-greeter-settings gnome-mahjongg hardinfo kid3 \
    network-manager-gnome parcellite pavucontrol quadrapassel \
    recordmydesktop gtk-recordmydesktop remmina sakura seahorse simple-scan \
    slack-desktop skypeforlinux solaar soundconverter spotify-client \
    synaptic system-config-printer thunderbird transmission-gtk tuxguitar \
    viewnior vino virtualbox-5.2 visualboyadvance vlc
[[ $? -ne 0 ]] && exit 1

# CLI applications
apt-get install autoconf cmake cowsay cups curl dkms docker-ce dos2unix \
    flashplayer-mozilla fonts-freefont-otf fortune g++ ghc gifsicle git \
    gvfs-backends handbrake-cli hunspell hunspell-en-us hunspell-it \
    imagemagick jq lame libgnome-keyring-dev lightdm-gtk-greeter lua5.1 \
    lua5.3 make oracle-java8-installer oracle-java8-set-default \
    browser-plugin-vlc p7zip python-pip python-requests-futures \
    python-setuptools python3-gdbm python3-lxml rar ruby sbt scala \
    shellcheck sudo thunar-archive-plugin thunar-dropbox-plugin tree \
    tuxguitar-jsa uni2ascii unrar virtualenvwrapper xdotool \
    xserver-xorg-input-synaptics yad zip
[[ $? -ne 0 ]] && exit 1

# --no-install-recommends prevents node from being installed
apt-get install --no-install-recommends yarn
[[ $? -ne 0 ]] && exit 1

# Sparky applications
# apt-get install sparky-about sparky-artwork sparky-apt sparky-codecs \
#    sparky-desktop-data sparky-editor sparky-eraser sparky-fontset \
#    sparky-grub-theme sparky-info sparky-keyring sparky-live-usb-creator \
#    sparky-nm-applet sparky-passwdchange sparky-remsu sparky-timedateset \
#    sparky-users sparky-usb-formatter sparky5-theme
#[[ $? -ne 0 ]] && exit 1

# Xfce plugins
apt-get install xfce4-battery-plugin xfce4-cpugraph-plugin xfce4-eyes-plugin \
    xfce4-mailwatch-plugin xfce4-power-manager xfce4-screenshooter \
    xfce4-sensors-plugin xfce4-taskmanager xfce4-terminal
[[ $? -ne 0 ]] && exit 1

# Rubygems
gem install bundle sass

# Cleaning again, so that if something undesired
# managed to get installed it is removed
clean

#####################################################
#
#                       Setup
#
#####################################################

# Docker non root access
grep docker /etc/group &> /dev/null || groupadd docker

# Git
ln -s /usr/share/doc/git/contrib/credential/gnome-keyring/git-credential-gnome-keyring \
    /usr/bin/git-credential-gnome-keyring

# Gnome Keyring on startup
make -C /usr/share/doc/git/contrib/credential/gnome-keyring
sed -r -i 's/OnlyShowIn=/OnlyShowIn=XFCE;/' \
    /etc/xdg/autostart/gnome-keyring-pkcs11.desktop

# Neo4j - preventing from auto-starting at boot
update-rc.d -f neo4j remove

# Sensor plugin
chmod u+s /usr/sbin/hddtemp

# Removing non-working .desktop files
NON_WORKING_DESKTOPS=(
    'brasero-nautilus'
    'conky'
    'enlightenment_filemanager_home'
    'lxpolkit'
)
for DESKTOP in "${NON_WORKING_DESKTOPS[@]}"; do
    rm /usr/share/applications/"$DESKTOP".desktop &> /dev/null
done
