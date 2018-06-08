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
sudo apt-get install git nfs-kernel-server nfs-common python-requests rcpbind
sudo apt-get upgrade

#####################################################
#
#           Enabling SSH root login
#
#####################################################

sudo sed -i -E 's/#.+PermitRootLogin .+$/PermitRootLogin yes/' /etc/ssh/sshd_config

#####################################################
#
#               Configuring NFS
#
#####################################################

sudo cp Support/raspberry/exports /etc

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
