#!/usr/bin/env bash

# Executing .profile
[[ -f "$HOME/.profile" ]] && source "$HOME/.profile"

# Setting environment variables
[[ -f "$HOME/.bash_envvars" ]] && source "$HOME/.bash_envvars"

# Executing .bashrc for interactive bash sessions
[[ -n "$BASH_VERSION" && "$-" =~ .*i.* && -f "$HOME/.bashrc" ]] \
    && source "$HOME/.bashrc"
