#!/usr/bin/env bash

# This script sets, for both user and root, the content and color of terminal
# prompt and the text in the title of terminal windows

#####################################################
#
#                   Variables
#
#####################################################

# Green
ROOT_PS1='\[\033[38;5;40m\]\u@\h:*/\W\$ '

# Title
TITLE='\[\e]0;\u@\h:*/\W\a\]'

# Orange
USER_PS1='\[\033[38;5;202m\]\u@\h:*/\W\$ '

#####################################################
#
#                   Functions
#
#####################################################

# This function sets the PS1 and the terminal title of a given user.
#
# Arguments:
#   - $1: The string PS1 should be set to
#   - $2: The user for which PS1 and terminal title are set
function set-ps1 {
    # PS1 backslashes are escaped to be used in double quotes
    local PS1="${1//\\/\\\\}"
    local USER_NAME="$2"

    # The most awkward way of getting a user's home directory
    echo "User: $USER_NAME"
    local USER_HOME=$(su "$USER_NAME" -c "echo \$HOME")

    # Checking for the title line
    if grep -P 'PS1=.+\$PS1' "$USER_HOME/.bashrc" &> /dev/null; then

        # Title line exists, replacing the title with sed
        TITLE=${TITLE//\\/\\\\}
        sudo sed -r -i "s|#?(.*)PS1=.+\\\$PS1\"?|\1PS1='$TITLE'\"\$PS1\"|g" \
            "$USER_HOME/.bashrc"
    else

        # Title line does not exist, appending it
        echo "# If this is an xterm set the title
case "\$TERM" in
xterm*|rxvt*)
    PS1='$TITLE'"\$PS1"
    ;;
*)
    ;;
esac
" | sudo tee -a "$USER_HOME/.bashrc" > /dev/null
    fi

    # Replacing all the PS1 assignments but the title one
    sudo sed -r -i "/PS1=.+\\\$PS1/! s|#?(.*)PS1=.+|\1PS1='$PS1'|g" \
        "$USER_HOME/.bashrc"
}

#####################################################
#
#                       Root
#
#####################################################

set-ps1 "$ROOT_PS1" 'root'

#####################################################
#
#                       User
#
#####################################################

set-ps1 "$USER_PS1" "$USER"
