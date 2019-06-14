#!/usr/bin/env sh

# This script installs packages not related to anything else on th system

. ./.env

#######################################
# Repositories dotfiles
#######################################

dotdrop --user root install -p packages
