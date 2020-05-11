#!/usr/bin/env zsh

# This script configures and loads zsh plugins

# {{@@ header() @@}}

#######################################
# Inheriting from POSIX shell
#######################################

source "$SDOTDIR/plugins/init.sh"

###############################################################################
#
#                               Pre-config
#
###############################################################################

#######################################
# deer
#######################################

autoload -U deer
zle -N deer
bindkey '\ed' deer

typeset -Ag DEER_KEYS
DEER_KEYS[down]=';'
DEER_KEYS[up]=p
DEER_KEYS[enter]="'"
DEER_KEYS[leave]=l

#######################################
# wd
#######################################

WD_CONFIG="$ZDOTDIR/plugins/dotfiles/.warprc"
WD_SKIP_EXPORT=true

wd() { . "$ANTIBODY_HOME/"*wd/wd.sh }

#######################################
# zsh-autopair
#######################################

typeset -gA AUTOPAIR_PAIRS
AUTOPAIR_PAIRS+=('<' '>')

AUTOPAIR_INHIBIT_INIT=true

#######################################
# zsh-autosuggestions
#######################################

ZSH_AUTOSUGGEST_STRATEGY='match_prev_cmd'
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=73'
ZSH_AUTOSUGGEST_USE_ASYNC=true

#######################################
# zsh-command-not-found
#######################################

ZSH_COMMAND_NOT_FOUND_NO_FAILURE_MSG=false

{%@@ if not is_headless @@%}
#######################################
# zsh-notify
#######################################

readonly ICON_THEME="$(xfconf-query -c xsettings -p /Net/IconThemeName)"
readonly ICON_THEME_PATH="$HOME/.icons/$ICON_THEME/scalable/emblems"

zstyle ':notify:*' command-complete-timeout 5
zstyle ':notify:*' error-icon "$ICON_THEME_PATH/emblem-important.svg"
zstyle ':notify:*' error-title 'Error - took #{time_elapsed}s'
zstyle ':notify:*' success-icon "$ICON_THEME_PATH/emblem-ok.svg"
zstyle ':notify:*' success-title 'OK - took #{time_elapsed}s'

{%@@ endif @@%}
#######################################
# zsh-syntax-highlight
#######################################

#ZSH_HIGHLIGHT_HIGHLIGHTERS+=brackets

#######################################
# zsh-you-should-use
#######################################

readonly SHELL_FORMAT_BOLD='\033[1m'
readonly SHELL_FORMAT_RESET='\033[0m'
readonly YSU_ALIAS_TYPE_COLOR='\033[38;5;33m'
readonly YSU_COMMAND_COLOR='\033[38;5;45m'
readonly YSU_ALIAS_COLOR='\033[38;5;81m'

YSU_MESSAGE_FORMAT="$YSU_ALIAS_TYPE_COLOR%alias_type$SHELL_FORMAT_RESET: \
$YSU_COMMAND_COLOR%command$SHELL_FORMAT_RESET -> \
$SHELL_FORMAT_BOLD$YSU_ALIAS_COLOR%alias$SHELL_FORMAT_RESET"
YSU_MESSAGE_POSITION='after'

###############################################################################
#
#                                   Load
#
###############################################################################

source "$ZDOTDIR/plugins/plugins-before-compinit.zsh"

autoload -Uz compinit bashcompinit
compinit
bashcompinit

source "$ZDOTDIR/plugins/plugins-after-compinit.zsh"

###############################################################################
#
#                               Post-config
#
###############################################################################

#######################################
# fasd
#######################################

source "$ZDOTDIR/cache/fasd"

#######################################
# thefuck
#######################################

# source "$ZDOTDIR/cache/thefuck"

#######################################
# zsh-autopair
#######################################

autopair-init

#######################################
# zsh-history-substring-search
#######################################

HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=2,fg=15,bold'
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='bg=9,fg=15,bold'
HISTORY_SUBSTRING_SEARCH_GLOBBING_FLAGS='l'
HISTORY_SUBSTRING_SEARCH_FUZZY='on'

bindkey "${key[Up]}" history-substring-search-up
bindkey "${key[Down]}" history-substring-search-down

setopt HIST_IGNORE_ALL_DUPS
