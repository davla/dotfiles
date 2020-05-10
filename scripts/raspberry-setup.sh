#!/usr/bin/env bash

# This script sets up my raspberry pi

#####################################################
#
#                   Variables
#
#####################################################

# Path of this script's parent directory
PARENT_DIR="$(dirname "${BASH_SOURCE[0]}")"
LIB_DIR="$PARENT_DIR/lib"

# Absolute path of raspberry configuration directory
RASPI_LIB_DIR="$(readlink -f "$LIB_DIR/raspberry")"

#####################################################
#
#               Setting root password
#
#####################################################

# NP stands for No Password
sudo passwd --status | grep -w 'NP' &> /dev/null && sudo passwd

#####################################################
#
#               Installing packages
#
#####################################################

sudo cp "$RASPI_LIB_DIR/sources/"*.list /etc/apt/sources.list.d

wget -O - 'https://download.docker.com/linux/raspbian/gpg' | sudo apt-key add -

sudo apt-get update

# This is removed as it breaks raspbian testing
sudo apt-get remove raspi-copies-and-fills
sudo apt-get install at certbot ddclient docker-ce git jq nfs-kernel-server \
    nfs-common python3-pip python-requests rpcbind
sudo apt-get upgrade

sudo pip3 install docker-compose

#####################################################
#
#               Configurations
#
#####################################################

# sudo cp "$RASPI_LIB_DIR/config/exports" /etc
# sudo cp "$RASPI_LIB_DIR/config/pam_login" /etc/pam.d/login
# sudo cp "$RASPI_LIB_DIR/config/pam_sshd" /etc/pam.d/sshd
# sudo cp "$RASPI_LIB_DIR/config/sshd_config" /etc/ssh/sshd_config
# sudo cp "$RASPI_LIB_DIR/config/rsyslog-custom.conf" /etc/rsyslog.d
# sudo cp "$RASPI_LIB_DIR/config/logrotate-custom.conf" /etc/logrotate.d
#
# Setting up ddclient. The lib configuration file is mean to override the
# ddclient one anytime; however, as it doesn't have the password, this is
# either grepped from the ddclient config file, if there is already one, or
# asked interactively.
# if [[ -f /etc/ddclient.conf ]]; then
#     DNS_PASSWD="$(sudo grep -oP 'password=\K.+' /etc/ddclient.conf)"
# else
#     read -sp 'Insert DNS service password: ' DNS_PASSWD
#     echo ''
# fi
# sudo cp "$RASPI_LIB_DIR/config/ddclient.conf" /etc
# sudo sed -i "7ipassword=$DNS_PASSWD" /etc/ddclient.conf
#
# sudo adduser "$USER" docker
#
# git config --global user.email 'truzzialrogo@gmx.com'
# git config --global user.name 'Davide Laezza'

#####################################################
#
#                   Shell setup
#
#####################################################

bash "$PARENT_DIR/shell-env.sh" "$RASPI_LIB_DIR"
source "$HOME/.bash_envvars"

#####################################################
#
#               SSH Keys creation
#
#####################################################

bash "$PARENT_DIR/ssh-keys.sh"

#####################################################
#
#              Setting cron jobs
#
#####################################################

crontab -u pi "$RASPI_LIB_DIR/pi-crontab"
sudo crontab -u root "$RASPI_LIB_DIR/root-crontab"

#####################################################
#
#           Installing pywikibot
#
#####################################################

# Only installing pywikibot if it's not already installed
if [[ ! -d "$PYWIKIBOT_DIR" ]]; then
    git clone --recursive 'https://gerrit.wikimedia.org/r/pywikibot/core.git' \
        "$PYWIKIBOT_DIR"

    # Adding some custom scripts and machineries
    ln -sf "$RASPI_CONF_DIR/pywikibot/"* "$PYWIKIBOT_DIR"
    mkdir -p "$PYWIKIBOT_DIR/dicts"

    cd "$PYWIKIBOT_DIR" || exit 1

    # Setting up the bot to connect to Pokémon Central Wiki
    python pwb.py generate_family_file \
        'https://bulbapedia.bulbagarden.net/wiki/Main_Page' ep
    python pwb.py generate_user_files
    python pwb.py login

    cd - &> /dev/null || exit 1
fi

#####################################################
#
#               Installing n
#
#####################################################

# Only installing n if it's not already installed
if ! which n &> /dev/null; then
    N_DIR='/tmp/n'

    git clone 'git@github.com:davla/n.git' "$N_DIR"
    sudo make -C "$N_DIR" install
    make -C "$N_DIR" use
    rm -rf "$N_DIR"

    # Installing the latest version to create the directory where n lib files
    # will be copied
    sudo n latest
    sudo cp -r "$LIB_DIR/n/"* /usr/local/n/versions/node
fi

#####################################################
#
#           Installing wiki-macros
#
#####################################################

# Only installing wiki macros if they'r not already there
if [[ ! -d "$UTIL_DIR" ]]; then
    git clone 'git@github.com:pokemoncentral/wiki-util.git' "$UTIL_DIR"

    # Installing coffeescript globally for the node version the macros are
    # meant to run on
    MACROS_DIR="$UTIL_DIR/js/atom-macros/"
    sudo n "$(< "$MACROS_DIR/.nvmrc")"
    sudo npm install -g coffeescript

    # Installing macros dependencies
    source "$HOME/.n-use.sh"
    cd "$MACROS_DIR" || exit 1
    n-use
    npm install
    cd - &> /dev/null || exit 1
fi

#####################################################
#
#           Setting terminal colors
#
#####################################################

bash "$PARENT_DIR/terminal-setup.sh" 'remote'
