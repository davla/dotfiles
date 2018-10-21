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

sudo cp Support/raspberry/sources/*.list /etc/apt/sources.list.d

wget -O - 'https://download.docker.com/linux/raspbian/gpg' | sudo apt-key add -

sudo apt-get update
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

sudo cp Support/raspberry/config/exports /etc
sudo cp Support/raspberry/config/pam_login /etc/pam.d/login
sudo cp Support/raspberry/config/pam_sshd /etc/pam.d/sshd
sudo cp Support/raspberry/config/sshd_config /etc/ssh/sshd_config
sudo cp Support/raspberry/config/rsyslog-custom.conf /etc/rsyslog.d
sudo cp Support/raspberry/config/logrotate-custom.conf /etc/logrotate.d

if [[ -f /etc/ddclient.conf ]]; then
    DNS_PASSWD=$(sudo grep -oP 'password=\K.+' /etc/ddclient.conf)
else
    read -sp 'Insert DNS service password: ' DNS_PASSWD
    echo ''
fi
sudo cp Support/raspberry/config/ddclient.conf /etc
sudo sed -i "7ipassword=$DNS_PASSWD" /etc/ddclient.conf

sudo adduser "$USER" docker

git config --global user.email 'truzzialrogo@gmx.com'
git config --global user.name 'Davide Laezza'

#####################################################
#
#                   Shell setup
#
#####################################################

# Setting PATH at every user switch, regardless of whether the shell is login
if ! sudo grep -P 'ALWAYS_SET_PATH\s+yes' /etc/login.defs &> /dev/null; then
    LINE_NO=$(sudo grep -n '^ENV_PATH' /etc/login.defs | cut -d ':' -f 1)
    LINE_NO=$(( LINE_NO + 1 ))

    sudo sed -i -e "$(( LINE_NO - 1 ))G" \
                -e "${LINE_NO}i#" \
                -e "${LINE_NO}i# Sets the PATH to one of the above values \
also for non-login shells" \
                -e "${LINE_NO}i#" \
                -e "${LINE_NO}iALWAYS_SET_PATH         yes" /etc/login.defs
fi

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
#              Setting cron jobs
#
#####################################################

crontab -u pi Support/raspberry/pi-crontab
sudo crontab -u root Support/raspberry/root-crontab

#####################################################
#
#               TSL certificate setup
#
#####################################################

if ! sudo certbot certificates 2> /dev/null | grep 'Found' &> /dev/null; then
    read -p 'Open port 80 as the TSL certificates are being installed'
    sudo certbot certonly --standalone -d 'maze0.hunnur.com' \
        -m 'truzzialrogo@gmx.com'
fi

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
#           Setting terminal colors
#
#####################################################

bash terminal-setup.sh 'raspberry'
