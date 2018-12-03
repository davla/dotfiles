#!/usr/bin/env bash

# This script takes care of all the locales related setup. In particular, it
# generates the desired locale languages, sets the default languages, sets the
# timezone and fixes the spellcheckers

#####################################################
#
#                   Privileges
#
#####################################################

# Checking for root privileges: if don't have them, recalling this script with
# sudo
if [[ $EUID -ne 0 ]]; then
    echo 'This script needs to be run as root'
    sudo bash "$0" "$@"
    exit 0
fi

#####################################################
#
#               Generating locales
#
#####################################################

LOCALES=(
    'en_DK.UTF-8 UTF-8'
    'en_US.UTF-8 UTF-8'
)

# Uncommenting selected locales in /etc/locale.gen
for LOCALE in "${LOCALES[@]}"; do
    sed -Ei "s/#\\s*(.*)$LOCALE/\\1$LOCALE/g" /etc/locale.gen
done

#####################################################
#
#               Setting defaults
#
#####################################################

echo 'LANG=en_DK.UTF-8
LC_ALL=en_DK.utf8
' > /etc/default/locale

#####################################################
#
#               Setting timezone
#
#####################################################

rm /etc/localtime
echo 'Europe/Copenhagen' > /etc/timezone

#####################################################
#
#               Applying changes
#
#####################################################

dpkg-reconfigure -f noninteractive locales
dpkg-reconfigure -f noninteractive tzdata

#####################################################
#
#               Fixing spellcheckers
#
#####################################################

ln -s ./en_US.aff /usr/share/hunspell/en_DK.aff
ln -s ./en_US.dic /usr/share/hunspell/en_DK.dic
