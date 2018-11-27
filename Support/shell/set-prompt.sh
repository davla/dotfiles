#!/usr/bin/env bash

# This script defines a function to set the PS1 variable. This function is
# meant to be run in PROMPT_COMMAND. This last step is not perfomed here, so
# as to provide further customization capabilities.
#
# The prompt is divided into three segments: user and host, current working
# directory and git information. Each segment can have a different background
# color; the text color is the same for all segments. The git segment is only
# displayed in git repositories. The shell symbol is displayed on a new line,
# below the user and host segment, in the same background as the latter.
#
# The colors are defined as a bunch of variables in a colorscheme file, to be
# found in the user home directory. If the file doesn't exist, the
# prompt-setting function is an alias to true.

# If the colorscheme file is found, triggering the whole machinery.
if [[ -f "$HOME/.prompt-colorscheme.sh" ]]; then
    # Most of the computation doesn't need to be repeated every time the prompt
    # is rendered. This is why they are before the prompt-setting function.

    # Reading the colorscheme
    source "$HOME/.prompt-colorscheme.sh"

    # The segments of the prompt before git, that is user and hostname and
    # current woking directory.
    PS1_PRE_GIT="$TEXT_COLOR$USER_HOST_BG \u@\h $CWD_BG */\W $RESET"

    # The shell symbol, on a newline.
    #
    # The newline is here, rather than at the end of the previous segments,
    # just for convenience: in fact, the last segment in the previous line
    # could be either the current wotking directory or git, meaning that some
    # logic should be written to find out where to append the newline.
    PS1_POST_GIT="\n$TEXT_COLOR$USER_HOST_BG └─\\$ $RESET "

    # Format string for the git segment. %s is where the git info will be.
    PS1_GIT_FORMAT="$TEXT_COLOR$GIT_BG [%s] $RESET"

    # If this is an xterm set the title to user@host:dir
    case "$TERM" in
        xterm*|rxvt*)
            PS1_PRE_GIT='\[\e]0;\u@\h:*/\W\a\]'"$PS1_PRE_GIT"
            ;;
        *)
            ;;
    esac

    # Git ps1 parameters:

    # Whether to show the presence of stashed elements ($)
    # shellcheck disable=SC2034
    GIT_PS1_SHOWSTASHSTATE=1

    # Whether to show the presence of untracked elements (%)
    # shellcheck disable=SC2034
    GIT_PS1_SHOWUNTRACKEDFILES=1

    # The separator between the branch name and the various indicators.
    # shellcheck disable=SC2034
    GIT_PS1_STATESEPARATOR=' '

    # Sourcing git prompt if __git_ps1 is not already defined.
    type __git_ps1 &> /dev/null || source /usr/lib/git-core/git-sh-prompt

    # This is the prompt-setting function. It just calls __git_ps1 with the
    # variables defined previously
    function set-prompt {
        __git_ps1 "$PS1_PRE_GIT" "$PS1_POST_GIT" "$PS1_GIT_FORMAT"
    }

# Colorscheme file not found, aliasing set-prompt to true
else
    shopt -s expand_aliases
    alias set-prompt='true'
fi
