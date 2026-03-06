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
. "$(dirname "$0")/../.dotfiles-env"
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

#######################################
# Telegram
#######################################

case "$HOST" in
    'personal')
        print_info 'Install Telegram'

        # Install the executables
        mkdir --parents "$TELEGRAM_HOME"
        wget --quiet --output-document - \
                'https://telegram.org/dl/desktop/linux' \
            | tar --extract --xz --directory "$TELEGRAM_HOME" \
                --strip-components 1

        # Link the main executable in $PATH
        ln --force --symbolic "$TELEGRAM_HOME/Telegram" \
            '/usr/local/bin/telegram'

        # Make updater work also for unprivileged users in telegram group
        groupadd --force telegram
        getent passwd telegram > /dev/null 2>&1 \
            || useradd --system --gid telegram telegram
        usermod --append --groups telegram "$USER_NAME"
        # Set telegram user login group to telegram, even if the user is not
        # created above
        usermod --gid telegram telegram
        chmod g+w "$TELEGRAM_HOME"
        chown telegram:telegram --recursive "$TELEGRAM_HOME"
        ;;
esac

#######################################
# Myrepos-based installation
#######################################

print_info 'Install myrepos'
apt-get install myrepos

print_info 'Install myrepos package management dotfiles'
dotdrop install -p manual -U root

MRCONFIG='/opt/mrconfig'
[ -s "$MRCONFIG" ] && {
    MRDIR="$(dirname "$MRCONFIG")"
    print_info 'Install myrepos-managed packages'
    mr --directory "$MRDIR" --config "$MRCONFIG" checkout
    mr --directory "$MRDIR" --config "$MRCONFIG" install
}

########################################
# GitHub releases-based installation
########################################

[ "$DISPLAY_SERVER" = 'headless' ] && {
    print_info 'gh-release not installed. Need a browser for authentication'
    exit 0
}

print_info 'Authenticate GitHub CLI'
sudo --user "$USER_NAME" sh -c \
    'gh auth status --active > /dev/null 2>&1 || gh auth login --web'
sudo --user "$USER_NAME" gh auth token | gh auth login --with-token

print_info 'Install gh-release'
dotdrop -U root install -p gh-release
sudo gh-release install
