#!/usr/bin/env zsh

# This script initializes the zsh dotfiles setup.

#######################################
# Loading environment
#######################################

# The shell environment needs to be loaded manually, rather than by the shell
# itself: indeed the dotfiles are not set up yet, as this very script is meant
# to do so, meaning that some errors would occur when the shell sources them.

. "$HOME/.dotdirs"
. "$ZDOTDIR/.zshenv"

#######################################
# Initializing $ZDOTDIR
#######################################

mkdir -p "${ZDOTDIR:?}/cache"

#######################################
# Installing antibody
#######################################

#######################################
# Installing plugind
#######################################

cd "$ZDOTDIR/plugins" || exit
< lists/plugins-before-compinit.list antibody bundle \
    > plugins-before-compinit.zsh
< lists/plugins-after-compinit.list antibody bundle \
    > plugins-after-compinit.zsh
cd - &> /dev/null || exit

#######################################
# Initializing cache
#######################################

fasd --init zsh-hook zsh-ccomp zsh-ccomp-install zsh-wcomp zsh-wcomp-install \
    > "${ZDOTDIR:?}/cache/fasd"

touch "${ZDOTDIR:?}/cache/zygal"
source "$ZDOTDIR/theme/dotfiles/zygal-conf.zsh"
zsh -ic zygal-static > "${ZDOTDIR:?}/cache/zygal"
