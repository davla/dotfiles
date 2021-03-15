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
. "$(dirname "$0")/../.env"

########################################
# Exit-early
########################################

[ "$DISTRO" = 'arch' ] && {
    printf '\e[32m[INFO]\e[0m Nothing to install manually via myrepos in Arch,'
    echo ' we have AUR :D'
    exit 0
}
[ "$HOST" = 'raspberry' ] && {
    printf '\e[32m[INFO]\e[0m Nothing to install manually via myrepos on the '
    echo 'raspberry'
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

echo '\e[32m[INFO]\e[0m Installing BitWarden'

# Downloading *.deb file
BITWARDEN_DEB="$(mktemp /tmp/bitwarden-deb.XXX)"
wget -qO "$BITWARDEN_DEB" \
    'https://vault.bitwarden.com/download/?app=desktop&platform=linux&variant=deb'

# Installing Debian package
dpkg --install "$BITWARDEN_DEB"

# Deleting *.deb file
rm "$BITWARDEN_DEB"

#######################################
# Telegram
#######################################

case "$HOST" in
    'personal')
        echo '\e[32m[INFO]\e[0m Installing Telegram'

        # Installing the executables
        mkdir -p "$TELEGRAM_HOME"
        wget -qO - 'https://telegram.org/dl/desktop/linux' \
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

# Installing myrepos
case "$DISTRO" in
    'arch')
        yay -S myrepos
        ;;

    'debian')
        apt-get install myrepos
        ;;
esac

# Installing manual package management dotfiles
dotdrop install -p manual -U root

# Installing myrepos-managed packages
mr -d /opt -c /opt/.mrconfig checkout
mr -d /opt -c /opt/.mrconfig install
