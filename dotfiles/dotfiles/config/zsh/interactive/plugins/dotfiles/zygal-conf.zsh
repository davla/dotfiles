#!/usr/bin/env zsh

# {{@@ header() @@}}

# This script contains zygal configuration

export ZYGAL_ASYNC='all'

export GIT_PS1_SHOWDIRTYSTATE=true
export GIT_PS1_SHOWSTASHSTATE=true
export GIT_PS1_SHOWUNTRACKEDFILES=true
export GIT_PS1_SHOWUPSTREAM='auto'
export GIT_PS1_STATESEPARATOR=' '

export ZYGAL_HG_DIRTY=true
export ZYGAL_HG_MISSING=true
export ZYGAL_HG_REMOTE=true
export ZYGAL_HG_SHELVE=true
export ZYGAL_HG_SEPARATOR=' '
export ZYGAL_HG_UNTRACKED=true

export ZYGAL_COLORSCHEME='{{@@ zygal_colorscheme @@}}'
