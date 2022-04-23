#!/usr/bin/env sh

# This script defines some POSIX shell aliases used in both interactive and
# non-interactive shells

#######################################
# Third-party commands aliases
#######################################

alias ls='exa'
alias tree='exa --tree'

########################################
# Shortening aliases
########################################

alias list-long='exa --all --binary --header --long --sort=type'
alias tree-long='list-long --tree --level=3'
