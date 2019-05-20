#!/usr/bin/env sh

# This script is meant as a dotdrop action to be executed after zsh dotfiles
# installation. It initializes zsh plugins and cache.

# Sourcing zsh environment variables
. "$HOME/.zshenv"

# Creating zsh cache directory
mkdir -p "$ZDOTDIR/cache"

# Install antibody
# Install plugins
cd "$ZDOTDIR/plugins" || exit
< lists/plugins-before-compinit.list antibody bundle \
    > plugins-before-compinit.zsh
< lists/plugins-after-compinit.list antibody bundle \
    > plugins-after-compinit.zsh
cd - /dev/null || exit

# Initializing cache
thefuck -a > "$ZDOTDIR/cache/thefuck"
fasd --init zsh-hook zsh-ccomp zsh-ccomp-install zsh-wcomp zsh-wcomp-install \
    > "$ZDOTDIR/cache/fasd"
touch "$ZDOTDIR/cache/zygal"
zsh zygal-static > "$ZDOTDIR/cache/zygal"
