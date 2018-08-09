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

sudo cp Support/raspberry/testing.list /etc/apt/sources.list.d

sudo apt-get update
sudo apt-get remove raspi-copies-and-fills
sudo apt-get install at git jq nfs-kernel-server nfs-common python-requests \
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
sudo cp Support/raspberry/config/rsyslog-custom.conf /etc/rsyslog.d
sudo cp Support/raspberry/config/logrotate-custom.conf /etc/logrotate.d

git config --global user.email 'truzzialrogo@gmx.com'
git config --global user.name 'Davide Laezza'

#####################################################
#
#           Adding environment variables
#
#####################################################

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

source ssh-keys.sh
echo 'Copy the key to GitHub so that the following clones will work'
cat "$SSH_HOME/id_rsa.pub"
read

# Changing this repository URL to use SSH
git remote get-url origin \
    | sed -E 's|https://(.+?)/(.+?)/(.+?).git|git@\1:\2/\3.git|' \
    | xargs git remote set-url origin

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
