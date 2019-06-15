#!/usr/bin/env sh

# This script sets up the system startup, including boot and both system and
# user startup jobs

. ./.env

#######################################
# Variables
#######################################

# Desktop files shell globs of user startup jobs which need to be delayed
USER_DELAYED='*npass*.desktop'

#######################################
# Setting up boot
#######################################

# The folliwing grub custom settings are set
#	- First OS in the list as the default choice
#	- Zero timeout
#	- Command line options to get brightness keys to work

sudo sed -r -i 's/GRUB_DEFAULT=[0-9]+/GRUB_DEFAULT=0/g' /etc/default/grub
sudo sed -r -i 's/GRUB_TIMEOUT=[0-9]+/GRUB_TIMEOUT=0/g' /etc/default/grub
sudo sed -r -i 's/GRUB_CMDLINE_LINUX_DEFAULT="(.*)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 acpi_backlight=vendor"/g' \
    /etc/default/grub

sudo update-grub

#######################################
# Setting up system/user startup jobs
#######################################

dotdrop --user both install -p startup

#######################################
# Further setup
#######################################

# Delaying some user autostart jobs

# Need the loop since every DELAYED item needs to be passed to find, as it can
# match multiple files
echo "$USER_DELAYED" | while read JOB; do
    # Prefixing the Exec command with sleep. The first sed pattern makes the
    # script idempotent, as it doesn't add sleep when it's already there.
    find "$HOME/.config/autostart" -name "$JOB" -exec sed -i -E \
        "/Exec=.*sleep/! s/Exec=(.+)/Exec=sh -c 'sleep 2s \&\& \1'/g" '{}' \;
done
