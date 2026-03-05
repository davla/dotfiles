#!/usr/bin/env sh

# This script installs Xfce desktop environment and its configuration

# This doesn't work if this script is sourced
. "$(dirname "$0")/lib.sh"

########################################
# Set up package managers
########################################

# This step is run early in the provisioning process. We should ensure that the
# package managers are actually setup
setup_package_managers

#######################################
# Installing Xfce
#######################################

print_info 'Install xfce'
case "$DISTRO" in
    'arch')
        # sudo apt-get install xfce4 xfce4-battery-plugin xfce4-cpugraph-plugin \
        #     xfce4-eyes-plugin xfce4-mailwatch-plugin xfce4-power-manager \
        #     xfce4-screenshooter xfce4-sensors-plugin xfce4-taskmanager
        # sudo apt-get purge xfce4-clipman xfce4-clipman-plugin xfce4-notes
        ;;

    'debian')
        sudo apt-get install alacritty xfce4 xfce4-battery-plugin \
            xfce4-cpugraph-plugin xfce4-eyes-plugin xfce4-mailwatch-plugin \
            xfce4-power-manager xfce4-screenshooter xfce4-sensors-plugin \
            xfce4-taskmanager
        sudo apt-get purge xfce4-clipman xfce4-clipman-plugin xfce4-notes
        ;;
esac

#######################################
# Installing Xfce dotfiles
#######################################

print_info 'Install xfce dotfiles'
dotdrop install -p xfce

#######################################
# Further setup
#######################################

# Sensor plugin
print_info 'Fix hddtemp permissions for sensor plugin'
sudo chmod u+s /usr/sbin/hddtemp

########################################
# Logout to load graphic session
########################################

if [ "$DISPLAY_SERVER" != 'x11' ]; then
    echo 'Logout necessary to load the graphic session. Press enter...'
    # shellcheck disable=SC2034
    read -r ANSWER
    loginctl terminate-user "$USER"
fi
