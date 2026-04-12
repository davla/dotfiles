#!/usr/bin/env sh

# This file contains utility code shared across bot steps

# This function returns the absolute paths where the files belonging to a
# dotdrop profile are installed to.
#
# Arguments:
#   - $1: The dotdrop profile whose files will be returned
#   - $2: The user the dotdrop profile belongs to. Optional, defaults to "user"
dotdrop_files() (
    DOTDROP_PROFILE="$1"
    DOTDROP_USER="${2:-user}"

    dotdrop files -bGp "$DOTDROP_PROFILE" -U "$DOTDROP_USER" 2> /dev/null \
        | cut --delimiter ',' --fields 2 | cut --delimiter ':' --fields 2
)

# This function prints a line with an informative message, that is a string
# prefixed by a green "[INFO]"
#
# Arguments:
#   - n: don't print final newline.
#   - $1: the message to be printed.
print_info() (
    NEWLINE='\n'
    while getopts ':n' OPTION; do
        case "$OPTION" in
            'n')
                NEWLINE=''
                ;;

            *)
                echo >&2 "print_info: unknown flag: $OPTION"
                exit 63
                ;;
        esac
    done
    shift $(( OPTIND - 1 ))

    printf "\e[32m[INFO]\e[0m %s$NEWLINE" "$1"
)
