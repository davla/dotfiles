#!/usr/bin/env bash

source "$HOME/.bash_envvars"

# Updates pywikibot

cd "$PYWIKIBOT_DIR" || exit 1
LOGFILE='./logs/update.log'

[[ $(git pull --all | wc -l) -gt 2 ]] \
    && echo 'Pywikibot updated on' "$(date +'%d-%m-%Y %T')" >> "$LOGFILE"
[[ -n $(git submodule update) ]] \
    && echo 'Submodules updated on' "$(date +%d-%m-%Y %T)" >> "$LOGFILE"
