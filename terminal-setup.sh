#!/usr/bin/env bash

# This script sets, for both user and root, the content and color of terminal
# prompt and the text in the title of terminal windows, The color varies based
# on the specified host.

# Arguments:
#   - $1: The host used to choose the colors. So far, one of:
#       - local
#       - raspberry

#####################################################
#
#                   Variables
#
#####################################################

# PS1s for different hosts. As bash does not allow nested arrays, the first
# line is root and the second is current user
declare -A PS1S

PS1S[local]='\[\033[38;5;40m\]\u@\h:*/\W\$
\[\033[38;5;202m\]\u@\h:*/\W\$'

PS1S[raspberry]='\[\033[38;5;11m\]\u@\h:*/\W\$
\[\033[38;5;39m\]\u@\h:*/\W\$'

# Title
TITLE='\[\e]0;\u@\h:*/\W\a\]'

#####################################################
#
#                   Parameters
#
#####################################################

# Host to choose the colors from
HOST="$1"

#####################################################
#
#                   Functions
#
#####################################################

# This function sets the PS1 and the terminal title of a given user.
#
# Arguments:
#   - $1: The string PS1 should be set to
#   - $2: The user home directory
function set-ps1 {
    # PS1 backslashes are escaped to be used in double quotes
    local PS1="${1//\\/\\\\} "
    local USER_HOME="$2"

    # If PS1 has already been set, returning
    grep "$PS1" "$USER_HOME/.bashrc" &> /dev/null && return

    # Checking for the title line
    if grep -P 'PS1=.+\$PS1' "$USER_HOME/.bashrc" &> /dev/null; then

        # Title line exists, replacing the title with sed
        TITLE=${TITLE//\\/\\\\}
        sudo sed -r -i "s|#?(.*)PS1=.+\\\$PS1\"?|\1PS1='$TITLE'\"\$PS1\"|g" \
            "$USER_HOME/.bashrc"
    else

        # Title line does not exist, appending it
        echo "# If this is an xterm set the title
case \"\$TERM\" in
xterm*|rxvt*)
    PS1='$TITLE'\"\$PS1\"
    ;;
*)
    ;;
esac
" | sudo tee -a "$USER_HOME/.bashrc" > /dev/null
    fi

    # Replacing all the PS1 assignments but the title one
    sudo sed -i -E "/PS1=.+\\\$PS1/! s|#?(.*)PS1=.+|\1PS1='$PS1'|g" \
        "$USER_HOME/.bashrc"
}

#####################################################
#
#                       Root
#
#####################################################

ROOT_PS1=$(head -n 1 <<< "${PS1S[$HOST]}")
set-ps1 "$ROOT_PS1" '/root'

#####################################################
#
#                       User
#
#####################################################

USER_PS1=$(tail -n 1 <<< "${PS1S[$HOST]}")
set-ps1 "$USER_PS1" "$HOME"
