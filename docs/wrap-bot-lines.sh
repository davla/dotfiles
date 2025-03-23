#!/usr/bin/env sh

# This script wraps what the bot says in documentation files.
# For more information, read the help text below.

########################################
# Default argument values
########################################

BOT_FACE_REGEX='^!\S+'
END_LINE='$'
HARD_WRAP='  '
INDENT='![     ][indent]'
LINE_LENGTH='114'
START_LINE='1'

########################################
# Help text
########################################

HELP_TEXT="Wrap what the bot says in documentation files.

Wrapped text is output to STDOUT. Input is read from a file, optionally within
a line number range.

Even though there are a number of parameters, the defaults are meant for the
markdown files used in this repository when displayed on the GitHub website.

Arguments:
    \$1: File with bot lines to be wrapped, optionally within a line number
         range.

Options:
    --bot-face-regex <regex>   The PERL regex used to identify the bot face at
    -F REGEX                   the beginning of lines.
                               Defaults to a markdown image with no spaces
                               allowed in the alternative text
                               ('$BOT_FACE_REGEX').

    --end-line INT             The line number of the last input line to be
    -E INT                     wrapped.
                               Defaults to the last line.

    --hard-wrap <text>         The string used as a hard line break, in
    -W TEXT                    addition to newlines.
                               Defaults to double space, as in markdown syntax.

    --indent <text>            The text used to indent wrapped lines.
    -I TEXT                    Defaults to a markdown image reference to the
                               indent svg in this repository, padded to match
                               the length of
                               ('$INDENT').

    --line-length <int>        The maximum length of bot text lines,
    -L INT                     *excluding* the bot face. Longer lines are
                               wrapped.
                               Defaults to $LINE_LENGTH.

    --start-line INT           The line number of the first input line to be
    -S INT                     wrapped.
                               Defaults to $START_LINE.

    --help                     Display this help text.
    -H
"

########################################
# Functions
########################################

# This function returns successfully only if the argument is an integer without
# a sign, that is a string of digits
is_unsinged_int() {
    case "$1" in
        ''|*[!0-9]*)
            return 1
            ;;
        *)
            return 0
    esac
}

########################################
# Input processing
########################################

INPUT_FILE=''
while [ $# -gt 0 ]; do
    case "$1" in
        '--bot-face-regex'|'-F')
            BOT_FACE_REGEX="^$2"
            shift
            ;;

        '--end-line'|'-E')
            END_LINE="$2"
            shift
            ;;

        '--hard-wrap'|'-W')
            HARD_WRAP="$2"
            shift
            ;;

        '--help'|'-H')
            echo "$HELP_TEXT"
            exit 0
            ;;

        '--indent'|'-I')
            INDENT="$2"
            shift
            ;;

        '--line-length'|'-L')
            LINE_LENGTH="$2"
            shift
            ;;

        '--start-line'|'-S')
            START_LINE="$2"
            shift
            ;;

        *)
            case "$1" in
                '-'*)
                    echo >&2 "Unknown option: $1"
                    exit 64
                    ;;
            esac

            [ -n "$INPUT_FILE" ] && {
                echo >&2 'Too many positional arguments'
                exit 63
            }

            INPUT_FILE="$1"
    esac
    shift
done

# Validity checks

[ ! -f "$INPUT_FILE" ] && {
    echo >&2 "'$INPUT_FILE' is not a file"
    exit 62
}

! is_unsinged_int "$START_LINE" && {
    echo >&2 "Start line is not an unsigned integer: $START_LINE"
    exit 61
}
if [ "$END_LINE" != '$' ] && ! is_unsinged_int "$END_LINE"; then
    echo >&2 "END_LINE line is not an unsigned integer: $END_LINE"
    exit 60
fi

########################################
# Main
########################################

[ "$END_LINE" != '$' ] \
    && SED_LINE_QUIT=";$(( END_LINE + 1 ))q" \
    || SED_LINE_QUIT=''

BOT_FACE_MAX_LENGTH="$(grep --perl-regexp --only-match "$BOT_FACE_REGEX" \
        "$INPUT_FILE" | wc --max-line-length)"

# Pad indent to match max bot face length
INDENT="$(printf "%-${BOT_FACE_MAX_LENGTH}s" "$INDENT")"

# Account for the space between the bot face and the text
LINE_LENGTH="$(( LINE_LENGTH - 1 ))"

sed --quiet "$START_LINE,${END_LINE}p$SED_LINE_QUIT" < "$INPUT_FILE" \
    | while read -r LINE; do
        BOT_FACE="$(echo "$LINE" \
            | grep --perl-regexp --only-match "$BOT_FACE_REGEX")"
        echo "$LINE" | sed --regexp-extended "
                s/$BOT_FACE_REGEX //;
                s/$HARD_WRAP$//
            " \
            | fold --space --width "$LINE_LENGTH" \
            | sed "
                1 s/^/$BOT_FACE /;
                2,$ s/^/$INDENT /
                s/\s*$/$HARD_WRAP/;
            "
    done
