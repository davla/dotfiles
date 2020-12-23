#!/usr/bin/env zsh

# This script initializes zsh

########################################
# Loading interactive setup
########################################

source "$ZDOTDIR/interactive/init.zsh"

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

#######################################
# Misc
#######################################

# Set up the prompt

#autoload -Uz promptinit
#promptinit

setopt nomultios

bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word

# Use emacs keybindings even if our EDITOR is set to vi
#bindkey -e

# Use modern completion system
#autoload -Uz compinit bashcompinit
#compinit
#bashcompinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)EXA_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
