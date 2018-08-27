#!/usr/bin/env bash

# This script sets up my raspberry pi

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

sudo cp Support/raspberry/sources/testing.list /etc/apt/sources.list.d
sudo cp Support/raspberry/sources/docker.list /etc/apt/sources.list.d

wget -O - 'https://download.docker.com/linux/raspbian/gpg' |  apt-key add -

sudo apt-get update
sudo apt-get remove raspi-copies-and-fills
sudo apt-get install at docker-ce git jq nfs-kernel-server nfs-common \
    python3-pip python-requests rcpbind
sudo apt-get upgrade

sudo pip3 install -y docker-compose

#####################################################
#
#               Configurations
#
#####################################################

sudo cp Support/raspberry/config/exports /etc
sudo cp Support/raspberry/config/pam_login /etc/pam.d/login
sudo cp Support/raspberry/config/pam_sshd /etc/pam.d/sshd
sudo cp Support/raspberry/config/sshd_config /etc/ssh/sshd_config
sudo cp Support/raspberry/config/rsyslog-custom.conf /etc/rsyslog.d
sudo cp Support/raspberry/config/logrotate-custom.conf /etc/logrotate.d

sudo adduser "$USER" docker

git config --global user.email 'truzzialrogo@gmx.com'
git config --global user.name 'Davide Laezza'

#####################################################
#
#                   Shell setup
#
#####################################################

# Shimming `su` to execute `su -` when called with no arguments
grep 'function su' /etc/bash.bashrc &> /dev/null \
    || tail -n +2 Support/shell/su.sh \
        | sudo tee -a /etc/bash.bashrc &> /dev/null

# Adding environment variables
cp Support/raspberry/.bash_envvars "$HOME"
grep '\.bash_envvars' "$HOME/.bashrc" &> /dev/null || echo '
# Setting envvars
if [ -f ~/.bash_envvars ]; then
    . ~/.bash_envvars
fi' >> "$HOME/.bashrc"
source "$HOME/.bash_envvars"

#####################################################
#
#               SSH Keys creation
#
#####################################################

bash ssh-keys.sh

#####################################################
#
#           Installing pywikibot
#
#####################################################

if [[ ! -d "$PYWIKIBOT_DIR" ]]; then
    git clone --recursive 'https://gerrit.wikimedia.org/r/pywikibot/core.git' \
        "$PYWIKIBOT_DIR"
    cp -r Support/raspberry/pywikibot/* "$PYWIKIBOT_DIR"
    mkdir -p "$PYWIKIBOT_DIR/dicts"
    cd "$PYWIKIBOT_DIR" || exit 1

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

if ! which n &> /dev/null; then
    N_DIR='/tmp/n'

    git clone 'git@github.com:davla/n.git' "$N_DIR"
    sudo make -C "$N_DIR" install
    make -C "$N_DIR" use
    rm -rf "$N_DIR"

    sudo n latest
    sudo cp -r Support/n/* /usr/local/n/versions/node
fi

#####################################################
#
#           Installing wiki-macros
#
#####################################################

if [[ ! -d "$UTIL_DIR" ]]; then
    git clone 'git@github.com:pokemoncentral/wiki-util.git' "$UTIL_DIR"

    MACROS_DIR="$UTIL_DIR/js/atom-macros/"
    sudo n "$(< "$MACROS_DIR/.nvmrc")"
    sudo npm install -g coffeescript

    source "$HOME/.n-use.sh"
    cd "$MACROS_DIR" || exit 1
    n-use
    npm install
    cd - &> /dev/null || exit 1
fi

#####################################################
#
#              Setting cron jobs
#
#####################################################

crontab -u pi Support/raspberry/pi-crontab
sudo crontab -u root Support/raspberry/root-crontab

#####################################################
#
#           Setting terminal colors
#
#####################################################

bash terminal-setup.sh 'raspberry'
