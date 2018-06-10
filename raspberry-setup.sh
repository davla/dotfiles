#!/usr/bin/env bash

# This script sets up my raspberry pi

#####################################################
#
#               Setting root password
#
#####################################################

sudo passwd

#####################################################
#
#               Installing packages
#
#####################################################

sudo cp Support/raspberry/testing.list /etc/apt/sources.list.d

sudo apt-get update
sudo apt-get remove raspi-copies-and-fills
sudo apt-get install git jq nfs-kernel-server nfs-common python-requests \
    rcpbind
sudo apt-get upgrade

#####################################################
#
#               Configurations
#
#####################################################

sudo cp Support/raspberry/config/exports /etc
sudo cp Support/raspberry/config/pam_login /etc/pam.d/login
sudo cp Support/raspberry/config/pam_sshd /etc/pam.d/sshd
sudo cp Support/raspberry/config/sshd_config /etc/ssh/sshd_config

#####################################################
#
#           Adding environment variables
#
#####################################################

cp Support/raspberry/.bash_envvars "$HOME"
echo 'source "$HOME/.bash_envvars"' >> "$HOME/.bashrc"
source "$HOME/.bash_envvars"

#####################################################
#
#           Installing pywikibot
#
#####################################################

git clone --recursive 'https://gerrit.wikimedia.org/r/pywikibot/core.git' \
    "$PYWIKIBOT_DIR"
cp -r Support/raspberry/pywikibot/* "$PYWIKIBOT_DIR"
cd "$PYWIKIBOT_DIR" || exit 1

python pwb.py generate_family_file 'https://wiki.pokemoncentral.it/Home' ep
python pwb.py generate_user_files
python pwb.py login

cd - &> /dev/null || exit 1

#####################################################
#
#               Installing n
#
#####################################################

N_DIR='/tmp/n'

git clone 'https://github.com/davla/n.git' "$N_DIR"
sudo make -C "$N_DIR" install
make -C "$N_DIR" use
rm -rf "$N_DIR"

sudo n latest
sudo cp -r Support/n/* /usr/local/n/versions/node

#####################################################
#
#           Installing wiki-macros
#
#####################################################

git clone 'https://github.com/pokemoncentral/wiki-util.git' "$UTIL_DIR"

MACROS_DIR="$UTIL_DIR/js/atom-macros/"
sudo n "$(< "$MACROS_DIR/.nvmrc")"
sudo npm install -g coffeescript

source "$HOME/.n-use.sh"
cd "$MACROS_DIR" || exit 1
n-use
npm install
cd - &> /dev/null || exit 1

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
