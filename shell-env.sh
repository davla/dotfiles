#!/usr/bin/env bash

# This script sets up the environment for new shells

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
sudo cp Support/shell/completion/* /etc/bash_completion.d/

#####################################################
#
#                       User
#
#####################################################

# Absolute path of shell configuration directory
SHELL_CONF_DIR="$(readlink -f Support/shell/)"

# Setting environment for bash login shells
ln -sf "$SHELL_CONF_DIR/.bash_profile" "$HOME"

# Setting custom environment variables for the user
ln -sf "$SHELL_CONF_DIR/.bash_envvars" "$HOME"
grep '\.bash_envvars' "$HOME/.bashrc" &> /dev/null || echo '
# Setting envvars
[ -f $HOME/.bash_envvars ] && . $HOME/.bash_envvars' >> "$HOME/.bashrc"
