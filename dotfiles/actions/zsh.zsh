#!/usr/bin/env zsh

# This script initializes the zsh dotfiles setup.
#
# Arguments:
#   - $1: The file defining the zsh configuration directory path.

# This doesn't work if this script is sourced
. "$(dirname "$0")/../../.dotfiles-env"
. "$(dirname "$0")/../../scripts/lib.sh"

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

########################################
# Variables
########################################

ZSH_CACHE_DIR="${ZDOTDIR:?}/cache"
ZSH_PLUGINS_DIR="${ZDOTDIR:?}/interactive/plugins"

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
# Initialize $ZDOTDIR
#######################################

mkdir --parents "${ZDOTDIR:?}/cache" "${ZDOTDIR:?}/interactive/plugins/data" \
    "${ZDOTDIR:?}/interactive/plugins/dotfiles"

#######################################
# Install antibody
#######################################

print_info 'Install antibody'
case "$DISTRO" in
    'arch')
        sudo -u "${SUDO_USER:-$(id -un)}" yay -S --needed antibody-bin
        ;;

    'debian')
        sudo mr --directory /opt/antibody --config /opt/.mrconfig install
        sudo mr --directory /opt/asdf-vm --config /opt/.mrconfig install
        ;;
esac

#######################################
# Install plugins
#######################################

print_info 'Install zsh plugins'

antibody bundle \
    < "$ZSH_PLUGINS_DIR/lists/plugins-before-compinit.list" \
    > "$ZSH_PLUGINS_DIR/plugins-before-compinit.zsh"
antibody bundle \
    < "$ZSH_PLUGINS_DIR/lists/plugins-after-compinit.list" \
    > "$ZSH_PLUGINS_DIR/plugins-after-compinit.zsh"

#######################################
# Initialize cache
#######################################

zsh "$ZDOTDIR/interactive/write-cache.zsh" --info --journald off
