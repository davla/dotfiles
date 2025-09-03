#!/usr/bin/env sh

# This script defines some POSIX shell functions that are useful in
# interactive shells only

{%@@ if user == 'user' and 'arch' in distro_id
    and not is_headless | is_truthy -@@%}

########################################
# Login functions
########################################

# This function starts the graphical session of my choice, only if executed in
# interactive and login shells on tty1 and only when another instance of the
# same session is not already running.
start_graphical_session() {
    case "$-" in
        # Interactive login shell
        *i*l*|*l*i*)
            # So far I only start sway this way. Let's not overengineer it
            [ "$TTY" = /dev/tty1 ] && [ -z "$WAYLAND_DISPLAY" ] && {
                systemd-cat --identifier=sway --stderr-priority=err sway
            }
            ;;
    esac
}

{%@@ endif -@@%}

#######################################
# Random from the Web
#######################################

alias wget-stdout='wget --quiet --output-document -'

# This function displays a dragon telling a random Chuck Norris fact
chuck() {
    wget-stdout 'https://api.chucknorris.io/jokes/random' \
        | jq --raw-output '.value' | cowsay -W 60 -f blowfish
}

# This function displays a milk carton telling a random dad joke
dad-joke() {
    {
        wget-stdout --header 'Accept: text/plain' https://icanhazdadjoke.com/
        echo
    } | cowsay -W 60 -f milk
}

# This function displays a stegosaurus telling a random fact
fact() {
    wget-stdout 'https://uselessfacts.jsph.pl/api/v2/facts/random' \
        | jq --raw-output '.text' | cowsay -W 60 -f stegosaurus
}

# This function displays a stupid-looking slice of cheese telling a random
# Trump quote
trump() {
    wget-stdout 'https://api.tronalddump.io/random/quote' \
        | jq --raw-output '.value' | cowsay -W 60 -f cheese
}

########################################
# Typo functions
########################################

# This function corrects my frequent swapping of the space and the t in git
# command (e.g. gi tcommit).
#
# Arguments:
#   - $1: The git command prefixed with a t (e.g. tlog)
#   - $2+: The other git arguments
gi() {
    # Stripping the t from the first argument
    1="$(echo $1 | sed 's/^t//')"

    # Executing git command
    git "$@"
}
