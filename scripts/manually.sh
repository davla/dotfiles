#!/usr/bin/env sh

# This script installs manually managed packages and applications and performs
# their initial setup. Non self-updating applications are managed via myrepos,
# while the other ones have custom installation process.
#
# Arguments:
#   - $1: The user added to the telegram group. Optional, defaults to $USER.

. ./.env

#######################################
# Variables
#######################################

# The directory where Telegram will be installed
TELEGRAM_HOME='/opt/telegram'

#######################################
# Input processing
#######################################

USER_NAME="${1:-$USER}"

#######################################
# Self-updating applications
#######################################

#######################################
# Telegram
#######################################

case "$HOSTNAME" in
    'personal')
        # Installing the executables
        mkdir -p "$TELEGRAM_HOME"
        wget -qO - 'https://tdesktop.com/linux' \
            | tar -xJC "$TELEGRAM_HOME" --strip-components=1

        # Linking the main executable in $PATH
        ln -sf "$TELEGRAM_HOME/Telegram" '/usr/local/bin/telegram'

        # Making updater work also for unprivileged users in telegram group
        groupadd -f telegram
        getent passwd telegram > /dev/null 2>&1 || useradd -r -g telegram \
            telegram
        usermod -aG telegram "$USER_NAME"
        # Setting telegram user login group to telegram, even if the user is
        # not created above
        usermod -g telegram telegram
        chmod g+w "$TELEGRAM_HOME"
        chown telegram:telegram -R "$TELEGRAM_HOME"
        ;;
esac

#######################################
# Myrepos-based installation
#######################################

case "$DISTRO" in
    'arch')
        yay -S myrepos
        ;;

    'debian')
        apt-get install myrepos
        ;;
esac

# Can't install the whole profile now. It contains dotfiles in directories
# created by checkout, which means that git clone would fail as the target
# directory is not empty.
dotdrop install -p manual f_mrconfig

mr -d '/opt' checkout

# Need bash to initialize ASDF environment variables
bash -lc 'source ./.env; dotdrop install -p manual'

mr -d '/opt' install
