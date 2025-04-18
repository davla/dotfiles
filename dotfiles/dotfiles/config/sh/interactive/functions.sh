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
# Core commands functions
#######################################

# This is a convenience function for exa long form. Other than calling exa with
# a bunch of nice options, it paginates the output if it doesn't fit in one
# screen, but without using a separate buffer.
#
# NOTE: It is not an alias since the parameters are not in last position.
#
# Arguments:
#   - $@: exa options to be added to the present ones, including the directory
#         to be listed. Optional.
list-long-paginated() {
    list-long --color=always --color-scale "$@" | paginate --RAW-CONTROL-CHARS
}

# This is a convenience function for exa tree form. Other than calling exa with
# a bunch of nice options, it paginates the output if it doesn't fit in one
# screen, but without using a separate buffer.
#
# Arguments:
#   - $1: Tree levels to be displayed. Optional, defaults to 2.
#   - $2+: exa options to be added to the present ones, including the directory
#          to be listed. Optional. It includes the first argument when it's not
#          a number.
tree-long-paginated() {
    T_LEVEL='3'
    echo "$1" | grep --extended-regexp '^[0-9]+$' > /dev/null 2>&1 && {
        T_LEVEL="$1"
        shift
    }

    tree-long --color=always --color-scale --level="$T_LEVEL" "$@" \
        | paginate --RAW-CONTROL-CHARS

    unset T_LEVEL
}

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
        list-long-paginated "$E_TARGET" "$@"
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
# Utility functions
########################################

# This is a utility function that operates with week numbers. It can perform a
# few seemingly unrelated tasks, based on the arguments it's called with:
#
# - It prints the current ISO week number, if called with no arguments.
# - It prints the Monday and Sunday of a week given its ISO number, if called
#   with a single number.
# - It prints the week number of a given day, if called with any number of
#   arguments that can concatenate to a date in any of these formats:
#   '%d-%m', '%d %m', '%d %b' or '%d-%b'
#
# Arguments:
#   - $1: Optional, but when present, one of:
#       - The week ISO number whose Monday and Sunday will be printed
#       - One of the element of the date whose ISO week number will be printed
#       - Nothing, to print the current ISO week number
#   - $2: Optional, the next element of the date whose ISO week number will be
#       printed
week() {

    # All the arguments concatenate to a single string of digits, i.e. a number.
    # Printing Monday and Sunday of the week having such ISO week number.
    echo "$@" | grep --extended-regexp '^[0-9]+$' > /dev/null 2>&1 && {

        # Week 1 is by definition the one containing the 4th of January. In
        # here we get the offset of the 4th of January from Monday of the same
        # week (the 4th of January's weekday as a number).
        WEEK_FOURTH_JAN_OFFSET="$(date --date='Jan 04' '+%u')"

        # Getting the Monday of the week having the given ISO number by:
        # - Landing in such week by offsetting by the given number of weeks
        #   from the 4th of January.
        # - Going back to the Monday of the same week by subtracting the offset
        #   the 4th of January had from the Monday of its own week.
        WEEK_GIVEN_MONDAY="$(date --date="Jan 04 + $(( $1 - 1 )) weeks \
            -  $(( WEEK_FOURTH_JAN_OFFSET - 1 )) days")"

        # `printf` to avoid printing the newline.
        date --date="$WEEK_GIVEN_MONDAY" '+%d %b' | xargs printf '%s %s - '
        date --date="$WEEK_GIVEN_MONDAY + 6 days" '+%d %b'

        unset WEEK_FOURTH_JAN_DAY WEEK_GIVEN_MONDAY
        return
    }

    # The sed script just swaps the date format to a decent day-month to the
    # goddammit degenerate American month-day -_-".
    echo "${@:-now}" | sed --regexp-extended 's|([0-9]+)([- ])(.+)|\3\2\1|g' \
        | xargs -I '{}' date --date='{}' '+%V'
}

########################################
# Abbreviation aliases
########################################

alias e='explore'
alias j='json-paginated'
alias l='list-long-paginated'
alias t='tree-long-paginated'
