#!/usr/bin/env zsh

# This script contains functions that are added as zsh hooks

########################################
# Environmed loading hook
########################################

# This function is meant to be used as a chpwd hook. It simply sources any .env
# file found in the current working directory, if any
function load_environment {
    [ -f .env ] && {
        echo 'Sourcing .env'
        source .env
    }
}

# Adding load_environment as a chpwd hook
add-zsh-hook chpwd load_environment
