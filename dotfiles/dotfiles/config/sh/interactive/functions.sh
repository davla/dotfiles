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

########################################
# Convenience functions
########################################

# This is a convenience function to explore the filesystem. It visualizes a
# path differently based on its content. In particular:
# - Directories: lists the content in long format with pagination
# - Binary files: opens the configured applications for their mime type
# - JSON files: displays with jq and pagination
# - Text files: displays with less
#
# Arguments:
#   - $1: The path to be inspected. Optional, defaults to the current directory
#   - $2+: Anything the selected visualization commands accepts. Optional.
explore() {
    E_TARGET="${1:-.}"
    [ "$#" -gt '0' ] && shift

    if [ -d "$E_TARGET" ]; then
        list-long "$E_TARGET" "$@"
    elif [ "$(file --brief --mime-encoding "$E_TARGET")" = 'binary' ]; then
        xdg-open "$E_TARGET"
    else
        # There's no way to tell JSON files apart than trying to parse them
        json-paginated "$E_TARGET" "$@" 2> /dev/null || less "$E_TARGET" "$@"
    fi

    unset E_TARGET
}

# This is a convenience function to pretty print a JSON file with pagination.
#
# NOTE: It is not an alias since the parameters are not in last position.
#
# Arguments:
# - $1: The file to be displayed.
# - $2+: Anyting jq accepts. Optional.
json-paginated() {
    # This is purposefully not cleaned with a trap. We're in a funciton here,
    # we don't want to overwrite the caller's traps.
    JSON_PAGINATED_TMP="$(mktemp XXX.json-paginaged.XXX)"

    jq --color-output '.' "$@" > "$JSON_PAGINATED_TMP"
    JSON_PAGINATED_EXIT="$?"
    paginate --RAW-CONTROL-CHARS "$JSON_PAGINATED_TMP"

    rm "$JSON_PAGINATED_TMP"
    unset JSON_PAGINATED_TMP
    return $JSON_PAGINATED_EXIT
}

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

########################################
# Abbreviation aliases
########################################

alias e='explore'
alias j='json-paginated'
