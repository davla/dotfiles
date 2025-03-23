#!/usr/bin/env sh

# This file contains utility code shared across bot steps

# This function prints a line with an informative message, that is a string
# prefixed by a green "[INFO]"
#
# Arguments:
#   - n: don't print final newline.
#   - $1: the message to be printed.
print_info() {
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
    unset NEWLINE OPTION
}
