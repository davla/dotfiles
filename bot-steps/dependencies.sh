#!/usr/bin/env sh

# This script installs this repository's dependencies:
# - sudo
# - uv
# - Devbox
#   + nix
# - Dotdrop
# - Secret decryption
#   + git secret
#   + rbw (for GPG key and password)

# This doesn't work if this script is sourced
. "$(dirname "$0")/lib.sh"

########################################
# Variables
########################################

BITWARDEN_PGP_ENTRY='PGP key'

#######################################
# Input processing
#######################################

DOTDROP_DIR="$1"

########################################
# Install repository packages
########################################

case "$DISTRO" in
    'arch')
        su --command 'pacman -S --needed --refresh gnupg nix rbw sudo'
        ;;

    'debian')
        su --command 'apt-get update \
            && apt-get install git-secret gnupg nix rbw sudo'
        ;;
esac

########################################
# User groups
########################################

groups "$USER" | grep --perl-regexp --quiet '(?=.*nix-users)(?=.*sudo)' || {
    print_info 'Allow sudo and non-root nix'
    su --command "/sbin/usermod --append --groups 'nix-users,sudo' '$USER'"
    echo 'Logout necessary to apply new groups. Press enter...'
    # shellcheck disable=SC2034
    read -r ANSWER
    loginctl terminate-user "$USER"
}

########################################
# Install uv
########################################

which uv > /dev/null 2>&1 || {
    print_info 'Install uv'
    case "$DISTRO" in
        'arch')
            sudo pacman -S --needed --refresh uv
            ;;

        'debian')
            # Quick-and-dirty uv installation. GitHub releases will take over
            # once provisioning is complete
            print_info 'Install uv'
            uname --machine | xargs -I '{}' wget --quiet --output-document - \
                    'https://github.com/astral-sh/uv/releases/latest/download/uv-{}-unknown-linux-gnu.tar.gz' \
                | sudo tar --extract --gzip --strip-components 1 \
                    --directory /usr/local/bin
            ;;
    esac
}

########################################
# Install devbox
########################################

# Quick-and-dirty devbox installation. AUR or GitHub releases will take over
# once provisioning is complete
which devbox > /dev/null 2>&1 || {
    print_info 'Install devbox'
    wget --quiet --output-document - 'https://get.jetify.com/devbox' | bash
}

#######################################
# Install dotdrop
#######################################

cd "$DOTDROP_DIR" || exit

print_info 'Recreate empty virtual environment'
devbox install
devbox run which python | xargs uv venv --clear --python

print_info 'Install project dependencies'
# Compiling bytecode now to ensure that created files have non-root
# permissions. By default uv compiles bytecode lazily the first time a command
# is executed in the virtual environment, and if that happens as root, then the
# files are created with root permissions.
uv sync --compile-bytecode

cd - > /dev/null 2>&1 || exit

########################################
# Import PGP key
########################################

print_info 'Retrieve private PGP key from Bitwarden'

rbw config show | grep --quiet '"email": null' && {
    printf 'Enter Bitwarden account email: '
    read -r BITWARDEN_EMAIL
    rbw config set email "$BITWARDEN_EMAIL"
}
rbw login

PGP_PASSWORD="$(rbw get "$BITWARDEN_PGP_ENTRY")"
[ -z "$(gpg --list-secret-keys)" ] &&
    rbw get "$BITWARDEN_PGP_ENTRY" --field 'notes' | gpg --batch --import \
        --pinentry-mode loopback --passphrase "$PGP_PASSWORD"

########################################
# Decrypt secrets
########################################

# Can't install git-secret via pacman because it's an AUR package
[ "$DISTRO" = 'arch' ] && ! which git-secret > /dev/null 2>&1 && {
    print_info 'Install of git-secret AUR package manually'

    CLONE_DIR="$(mktemp --directory 'XXX.git-secret.XXX')"
    # shellcheck disable=SC2064
    trap "rm --recursive --force $CLONE_DIR" EXIT HUP INT TERM
    git clone 'https://aur.archlinux.org/git-secret.git' "$CLONE_DIR"

    cd "$CLONE_DIR" || exit
    makepkg --syncdeps --install
    cd - > /dev/null 2>&1 || exit
}

print_info 'Decrypt git secrets'
git secret reveal -p "$PGP_PASSWORD"
