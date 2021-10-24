#!/usr/bin/env zsh

# This script configures and loads zsh plugins

# {{@@ header() @@}}

#######################################
# Inheriting from POSIX shell
#######################################

source "$SDOTDIR/interactive/plugins/shared.sh"

###############################################################################
#
#                               Pre-config
#
###############################################################################

{%@@ if env['DISTRO'] == 'arch' -@@%}

#######################################
# command-not-found
#######################################

source /usr/share/doc/pkgfile/command-not-found.zsh

{%@@ endif -@@%}

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

{%@@ if user == 'user' -@@%}

#######################################
# wd
#######################################

WD_CONFIG="$ZDOTDIR/interactive/plugins/dotfiles/warprc"
WD_SKIP_EXPORT=true

wd() { . "$ANTIBODY_HOME/"*wd/wd.sh }

{%@@ endif -@@%}

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

source "$ZDOTDIR/interactive/plugins/plugins-before-compinit.zsh"

autoload -Uz compinit bashcompinit
compinit
bashcompinit

source "$ZDOTDIR/interactive/plugins/plugins-after-compinit.zsh"

###############################################################################
#
#                               Post-config
#
###############################################################################

#######################################
# fasd
#######################################

export _FASD_DATA="$ZDOTDIR/interactive/plugins/data/.fasd"
export _FASD_SHELL='zsh'

source "$ZDOTDIR/cache/fasd"

#######################################
# thefuck
#######################################

source "$ZDOTDIR/cache/thefuck"

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

{%@@ if not is_headless | is_truthy
    and not (on_wayland | is_truthy and user == 'root') -@@%}

#######################################
# zsh-notify
#######################################

{%@@ set icon_theme_path = '/usr/share/icons/%s/scalable/emblems'
    | format(icon_theme) -@@%}

zstyle ':notify:*' app-name 'sh'
zstyle ':notify:*' command-complete-timeout 5
zstyle ':notify:*' error-icon "{{@@ icon_theme_path @@}}/emblem-important.svg"
zstyle ':notify:*' error-title 'Error - took #{time_elapsed}s'
zstyle ':notify:*' expire-time 2500
{%@@ if user == 'root' @@%}
zstyle ':notify:*' notifier 'zsh-notify-sudo-user'
{%@@ endif @@%}
zstyle ':notify:*' success-icon "{{@@ icon_theme_path @@}}/emblem-ok.svg"
zstyle ':notify:*' success-title 'OK - took #{time_elapsed}s'

{%@@ endif -@@%}
