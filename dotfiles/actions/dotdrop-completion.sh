#!/usr/bin/env sh

# This script installs dotdrop completion for bash and zsh
#
# Arguments:
#   - $1: The path to the the dotdrop configuration root directory.

# This doesn't work if this script is sourced
. "$(dirname "$0")/../../.dotfiles-env"
. "$(dirname "$0")/../../bot-steps/lib.sh"

########################################
# Variables
########################################

BASH_COMPLETIONS_DIR='/usr/local/share/bash-completion/completions'
URL_BASE='https://raw.githubusercontent.com/deadc0de6/dotdrop/refs/tags'
ZSH_COMPLETIONS_DIR='/usr/local/share/zsh/site-functions'

########################################
# Input processing
########################################

DOTDROP_DIR="$1"

########################################
# Main
########################################

print_info 'Install dotdrop shell completion'

########################################
# Retrieve dotdrop version
########################################

# The dotdrop version is used in the GitHub URL of the completion files
cd "$DOTDROP_DIR" || exit
DOTDROP_VERSION="$(uv run dotdrop --version)"
cd - > /dev/null 2>&1 || exit

########################################
# Install bash completion
########################################

sudo mkdir --parents "$BASH_COMPLETIONS_DIR"
sudo wget --quiet --output-document "$BASH_COMPLETIONS_DIR/dotdrop" \
    "$URL_BASE/v$DOTDROP_VERSION/completion/dotdrop-completion.bash"

########################################
# Install zsh completion
########################################

sudo mkdir --parents "$ZSH_COMPLETIONS_DIR"
sudo wget --quiet --output-document "$ZSH_COMPLETIONS_DIR/_dotdrop" \
    "$URL_BASE/v$DOTDROP_VERSION/completion/_dotdrop-completion.zsh"

