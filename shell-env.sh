#!/usr/bin/env bash

# This script sets up the environment for new shells

#####################################################
#
#                   Variables
#
#####################################################

# Absolute path of this script's parent directory
PARENT_DIR="$(dirname "${BASH_SOURCE[0]}")"
LIB_DIR="$PARENT_DIR/lib"

# Absolute path of lib directory for shell
SHELL_LIB_DIR="$(readlink -f "$LIB_DIR/shell")"

#####################################################
#
#                   System-wide
#
#####################################################

# Setting PATH at every user switch, regardless of whether the shell is login
if ! sudo grep -P 'ALWAYS_SET_PATH\s+yes' /etc/login.defs &> /dev/null; then
    LINE_NO=$(sudo grep -n '^ENV_PATH' /etc/login.defs | cut -d ':' -f 1)
    LINE_NO=$(( LINE_NO + 1 ))

    sudo sed -i -e "$(( LINE_NO - 1 ))G" \
                -e "${LINE_NO}i#" \
                -e "${LINE_NO}i# Sets the PATH to one of the above values \
also for non-login shells" \
                -e "${LINE_NO}i#" \
                -e "${LINE_NO}iALWAYS_SET_PATH         yes" /etc/login.defs
fi

# Enabling variables expansion and misspelling correction in autocompletion
grep '# Setting shell options for:' /etc/bash.bashrc &> /dev/null \
    || echo '
# Setting shell options for:
#   - Variables expansion in autocompletion
#   - Misspelling correction in autocompletion and cd
shopt -s direxpand dirspell cdspell' \
        | sudo tee -a /etc/bash.bashrc &> /dev/null

# Adding custom autocompletions
sudo cp "$SHELL_LIB_DIR/completion/"* /etc/bash_completion.d/

#####################################################
#
#                       User
#
#####################################################

# Setting environment for bash login shells
ln -sf "$SHELL_LIB_DIR/.bash_profile" "$HOME"

# Setting custom environment variables for the user
ln -sf "$SHELL_LIB_DIR/.bash_envvars" "$HOME"
grep '\.bash_envvars' "$HOME/.bashrc" &> /dev/null || echo '
# Setting envvars
[ -f $HOME/.bash_envvars ] && . $HOME/.bash_envvars' >> "$HOME/.bashrc"
