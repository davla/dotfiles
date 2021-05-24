#!/usr/bin/env sh

# This scripts defines some POSIX shell functions that are useful in
# interactive shells only

{%@@ if user == 'user' -@@%}

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
# NOTE: It is not an alias since the parameter is not in last position.
#
# Arguments:
#   - $@: exa options to be added to the present ones, including the directory
#         to be listed. Optional.
l() {
    exa --all --binary --color=always --color-scale --header --long \
            --sort=type "$@" \
        | less --no-init --quit-if-one-screen \
            --RAW-CONTROL-CHARS
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
t() {
    T_LEVEL='2'
    echo "$1" | grep --extended-regexp '^[0-9]+$' > /dev/null 2>&1 && {
        T_LEVEL="$1"
        shift
    }

    exa --all --binary --color=always --color-scale --header \
            --level="$T_LEVEL" --long --sort=type --tree "$@" \
        | less --no-init --quit-if-one-screen \
            --RAW-CONTROL-CHARS

    unset T_LEVEL
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

{%@@ if user == 'user' and env['HOST'] != 'work' -@@%}

# This is a utility function used to connect to/disconnect from NordVPN. Its
# main convenience consists in activating/deactivating the killswitch upon
# connection/disconnection, but it also uses some defaults of my choice when
# connecting.
#
# This function is therefore not meant to completely wrap the NordVPN CLI tool,
# because the CLI interface is well-designed enough to carry out less frequent
# operations.
#
# Arguments:
# - $1: Whether to connect/disconnect to NordVPN. One of:
#     - on/up: connects to NordVPN with some default parameters and activates
#              the killswitch
#     - off/down: disconnects from NordVPN and deactivates the killswitch
vpn() {
    case "$(echo "$1" | tr '[:upper:]' '[:lower:]')" in
        'on'|'up')
            nordvpn connect --group P2P Switzerland
            nordvpn set killswitch enabled
            ;;

        'off'|'down')
            nordvpn set killswitch disabled
            nordvpn disconnect
            ;;
    esac
}

{%@@ endif -@@%}

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
