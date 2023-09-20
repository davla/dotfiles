#!/usr/bin/env zsh

# This script initializes zsh login shells

{%@@ if user == 'user' and distro_id == 'arch'
    and not is_headless | is_truthy -@@%}

########################################
# Console login
########################################

case "$-" in
    # Interactive shells
    *i*)
        source "$SDOTDIR/interactive/functions.sh"
        start_graphical_session
        ;;
esac

{%@@ endif -@@%}
