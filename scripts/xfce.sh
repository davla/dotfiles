#!/usr/bin/env sh

# This script installs the Xfce desktop environment and its configuration

. ./.env

#######################################
# Installing Xfce
#######################################

sudo apt-get install xfce4 xfce4-battery-plugin xfce4-cpugraph-plugin \
    xfce4-eyes-plugin xfce4-mailwatch-plugin xfce4-power-manager \
    xfce4-screenshooter xfce4-sensors-plugin xfce4-taskmanager xfce4-terminal
sudo apt-get purge xfce4-clipman xfce4-clipman-plugin xfce4-notes

#######################################
# Installing Xfce dotfiles
#######################################

dotdrop install -p xfce

#######################################
# Further setup
#######################################

# Sensor plugin
sudo chmod u+s /usr/sbin/hddtemp
