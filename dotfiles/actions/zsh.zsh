#!/usr/bin/env zsh

# This script initializes the zsh dotfiles setup.
#
# Arguments:
#   - $1: The file defining the zsh configuration directory path.

# This doesn't work if this script is sourced
. "$(dirname "$0")/../../.dotfiles-env"
. "$(dirname "$0")/../../bot-steps/lib.sh"

#######################################
# Variables
#######################################

USER_NAME="$(id --user --name)"

#######################################
# Input processing
#######################################

DOTDIRS_FILE="${1:?}"

#######################################
# Load environment variables
#######################################

# This script needs zsh's environment variables to function correctly. However,
# they need to be loaded explicitly, because the dotfiles are indeed not fully
# set up yet, as this very script is meant to do so.

. "$DOTDIRS_FILE"
. "${ZDOTDIR:?}/.zshenv"

#######################################
# Create symbolic links
#######################################

# zsh offers the possibility to change the default config path by setting the
# ZDOTDIR environment variable. However, such variable needs to be set
# BEFORE zsh is initialized, making the setup very convoluted without using the
# default path. Therefore, the default path of first file to be loaded
# ($HOME/.zshenv) has been turned to a symlink to the actual file in the zsh
# configuration directory.

print_info 'Link zsh environment file in home directory'
ln --force --relative --symbolic "${ZDOTDIR:?}/.zshenv" "$HOME/.zshenv"

#######################################
# Install sheldon
#######################################

print_info 'Install sheldon'
case "$DISTRO" in
    'arch')
        sudo --user "${SUDO_USER:-$USER_NAME}" yay -S --needed sheldon
        ;;

    'debian')
        sudo gh-release install
        ;;
esac

#######################################
# Install plugins
#######################################

print_info 'Install zsh plugins'

SHELDON_PROFILE=''
case "$DISPLAY_SERVER" in
    'x11')
        SHELDON_PROFILE='gui'
        ;;

    'wayland')
        [ "$USER_NAME" != 'root' ] && SHELDON_PROFILE='gui'
        ;;
esac

sheldon --profile "$SHELDON_PROFILE" source \
    > "${ZDOTDIR:?}/interactive/plugins/load.zsh"

#######################################
# Initialize cache
#######################################

zsh "$ZDOTDIR/interactive/write-cache.zsh" --info --journald off
