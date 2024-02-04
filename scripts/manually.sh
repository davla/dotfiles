#!/usr/bin/env sh

# This script installs manually managed packages and applications and performs
# their initial setup. Non self-updating applications are managed via myrepos,
# while the others have a custom installation process.
#
# Some hosts/distros cause this script to exit early, as there's nothing to be
# manually installed
#
# Arguments:
#   - $1: The user added to the telegram group. Optional, defaults to $USER.

# This doesn't work if this script is sourced
. "$(dirname "$0")/lib.sh"

########################################
# Early-exit
########################################

[ "$DISTRO" = 'arch' ] && {
    print_info -n 'Nothing to install manually via myrepos in Arch, we have '
    echo 'AUR :D'
    exit 0
}
[ "$HOST" = 'raspberry' ] && {
    print_info 'Nothing to install manually via myrepos on raspberry'
    exit 0
}

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

########################################
# BitWarden
########################################

print_info 'Install BitWarden'

BITWARDEN_DEB="$(mktemp /tmp/bitwarden-deb.XXX)"
wget -qO "$BITWARDEN_DEB" \
    'https://vault.bitwarden.com/download/?app=desktop&platform=linux&variant=deb'

dpkg --install "$BITWARDEN_DEB"

rm "$BITWARDEN_DEB"

#######################################
# Telegram
#######################################

case "$HOST" in
    'personal')
        print_info 'Install Telegram'

        # Install the executables
        mkdir -p "$TELEGRAM_HOME"
        wget -qO - 'https://telegram.org/dl/desktop/linux' \
            | tar -xJC "$TELEGRAM_HOME" --strip-components=1

        # Link the main executable in $PATH
        ln --force --symbolic "$TELEGRAM_HOME/Telegram" \
            '/usr/local/bin/telegram'

        # Make updater work also for unprivileged users in telegram group
        groupadd -f telegram
        getent passwd telegram > /dev/null 2>&1 || useradd -r -g telegram \
            telegram
        usermod -aG telegram "$USER_NAME"
        # Set telegram user login group to telegram, even if the user is not
        # created above
        usermod -g telegram telegram
        chmod g+w "$TELEGRAM_HOME"
        chown telegram:telegram -R "$TELEGRAM_HOME"
        ;;
esac

#######################################
# Myrepos-based installation
#######################################

print_info 'Install myrepos'
case "$DISTRO" in
    'arch')
        pacman -S --needed myrepos
        ;;

    'debian')
        apt-get install myrepos
        ;;
esac

print_info 'Install myrepos package management dotfiles'
dotdrop install -p manual -U root

print_info 'Install myrepos-managed packages'
mr -d /opt -c /opt/.mrconfig checkout
mr -d /opt -c /opt/.mrconfig install
