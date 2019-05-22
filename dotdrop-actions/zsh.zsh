#!/usr/bin/env zsh

# This script installs zsh plugins and initializes the cache.

#######################################
# Initializing $ZDOTDIR
#######################################

mkdir -p "$ZDOTDIR/cache"

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
    > "$ZDOTDIR/cache/fasd"

touch "$ZDOTDIR/cache/zygal"
source "$ZDOTDIR/theme/dotfiles/zygal-conf.zsh"
zsh -ic zygal-static > "$ZDOTDIR/cache/zygal"
