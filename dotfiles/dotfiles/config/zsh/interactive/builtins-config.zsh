#!/usr/bin/env zsh

# This file contains configuration for zsh interactivity builtins, such as
# history and completion.

########################################
# Completion
########################################

setopt AUTO_LIST AUTO_MENU AUTO_PARAM_SLASH AUTO_REMOVE_SLASH \
    COMPLETE_IN_WORD LIST_AMBIGUOUS
unsetopt AUTO_NAME_DIRS COMPLETE_ALIASES MENU_COMPLETE LIST_BEEP LIST_PACKED

# Main
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' menu select=2 interactive
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

# Misc
zstyle ':completion:*:default' list-packed false
zstyle ':completion:*:default' show-ambiguity true
zstyle ':completion:*:default' single-ignored menu
zstyle ':completion:*' accept-exact-dirs true
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' ambiguous false

# Cache
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/completion"
zstyle ':completion:*' use-cache on

# Colors?
zstyle ':completion:*' list-colors ''
zstyle ':completion:*:default' list-colors ${(s.:.)EXA_COLORS} 'ma=1;38;5;208'
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'

# Grouping
zstyle ':completion:*:*:-command-:*:*' group-order alias builtins functions commands
zstyle ':completion:*:*:*:*:corrections' format '%F{227}??? %d (errors: %e) ???%f'
zstyle ':completion:*:*:*:*:descriptions' format '%F{34}--- %d ---%f'
zstyle ':completion:*:messages' format ' %F{51}+++ %d +++%f'
zstyle ':completion:*:warnings' format ' %F{160}!!! no matches found !!!%f'
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-grouped true

# Specific commands
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# Prompts
zstyle ':completion:*:default' list-prompt %SAt %p: TAB to scroll, or continue searching
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s

########################################
# History
########################################

setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FCNTL_LOCK
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_NO_FUNCTIONS
setopt HIST_REDUCE_BLANKS
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

export HISTFILE="$ZDOTDIR/.zsh_history"
export HISTORY_IGNORE="($HIST_IGNORED_CMDS|$HIST_IGNORED_GIT|$HIST_IGNORED_TYPOS)"
export HISTSIZE=1000
export SAVEHIST=1000
