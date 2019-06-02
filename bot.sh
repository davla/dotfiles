#!/usr/bin/env sh

. ./.env

#######################################
# Variables
#######################################

# Colors
RESET_COLOR='\033[0;0m'

ERROR_COLOR='\033[1;91m'
OK_COLOR='\033[1;92m'
PROMPT_COLOR='\033[1;93m'
SAD_COLOR='\033[1;96m'

# Exit codes
EXIT_NO=253
EXIT_SAY=245
EXIT_YES=0

# Faces
ERROR_FACE="${ERROR_COLOR}[>_<]${RESET_COLOR}"
OK_FACE="${OK_COLOR}[°o°]${RESET_COLOR}"
PROMPT_FACE="${PROMPT_COLOR}[^_^]${RESET_COLOR}"
SAD_FACE="${SAD_COLOR}[T.T]${RESET_COLOR}"

# Texts
CHOICES='[y/n/q] '
INDENT='      '
RETRY_PROMPT="Do you want to retry? $CHOICES"

# Misc
MSG_WIDTH="${1:-$COLUMNS}"
MSG_WIDTH="${MSG_WIDTH:-80}"
MSG_WIDTH=$(( MSG_WIDTH - $(printf "$INDENT" | wc -m) ))

# Reset
SHELL="$(ps --no-headers -p "$$" -o 'comm')"

#######################################
# Functions
#######################################

execute() {
    CMD="$1"
    DESC="$2"

    OUTPUT_LOG=$(mktemp)

    tput smcup
    tput cup 0 0

    tail -f "$OUTPUT_LOG" &
    $SHELL -c "$CMD" > "$OUTPUT_LOG" 2>&1
    CMD_EXIT="$?"
    printf 'Press enter to continue'
    read ANSWER
    kill "$!"

    tput rmcup

    if [ "$CMD_EXIT" -eq 0 ]; then
        say "$OK_FACE" "Looks like everything went fine with $DESC! Hooray!
The log has been saved to $OUTPUT_LOG. $RETRY_PROMPT"
    else
        say "$ERROR_FACE" "Looks like something went wrong with $DESC.
The log has been saved to $OUTPUT_LOG. $RETRY_PROMPT"
    fi

    if read_answer; then
        rm $OUTPUT_LOG
        execute "$@"
    else
        rm $OUTPUT_LOG
    fi

    unset CMD OUTPUT_LOG
}

goodbye() {
    SAY_OPTS="${1:-llt}"
    say -$SAY_OPTS "$SAD_FACE" "Saying goodbye early! Anything went wrong?"
    exit
}

prompt() {
    PROMPT="$1"
    CMD="$2"
    DESC="$3"

    say -l "$PROMPT_FACE" "Do you want to $PROMPT? $CHOICES"
    if read_answer; then
        execute "$CMD" "$DESC"
    else
        say -t "$PROMPT_FACE" "Skipping $DESC then."
    fi

    unset PROMPT CMD
}

read_answer() {
    read ANSWER
    case "$(echo "$ANSWER" | tr '[:upper:]' '[:lower:]')" in
        n|no)
            return "$EXIT_NO"
            ;;

        q|quit)
            goodbye lt
            ;;

        y|yes)
            return "$EXIT_YES"
            ;;
    esac
}

say() {
    OPTIND=0
    LEADING_NEWLINES=''
    TRAILING_NEWLINES=''
    while getopts 'lt' OPTION; do
        case "$OPTION" in
            'l')
                LEADING_NEWLINES="$LEADING_NEWLINES\n"
                ;;

            't')
                TRAILING_NEWLINES="$TRAILING_NEWLINES\n"
                ;;

            *)  # getopts has already printed an error message
                exit "$EXIT_SAY"
                ;;
        esac
    done
    shift $(( OPTIND - 1 ))
    FACE="$1"
    MSG="$2"

    MSG="$(printf "$MSG" | fold -sw "$MSG_WIDTH")"
    TAIL_LINES="$(printf "$MSG" | tail -n +2)"

    printf "$LEADING_NEWLINES"
    printf "$FACE"
    printf "$MSG" | head -n 1 | xargs -0 printf ' %s'
    [ -n "$TAIL_LINES" ] && {
        printf "$TAIL_LINES" | head -n -1 | awk "{print \"$INDENT\" \$0}"
        printf "$TAIL_LINES" | tail -n 1 | xargs -0 printf "$INDENT%s"
    }
    printf "$TRAILING_NEWLINES"

    unset FACE LEADING_NEWLINES MSG OPTION TAIL_LINES TRAILING_NEWLINES
}

#######################################
# Script
#######################################

trap goodbye INT TERM

say -t "$PROMPT_FACE" "Hello, I'm your setup script!
I'll guide you step-by-step through your system setup. I'll prompt you before \
each step, copy configuration files, execute commands, and report you output \
and errors when they occur.
Good luck, and let's hope it all goes well!"

prompt 'set dotdrop up' 'sh scripts/dotdrop.sh ./dotfiles' \
    'dotdrop setup'
prompt 'install your custom commands' 'sudo sh custom-commands/install.sh' \
    'custom commands installation'
prompt 'initialize the shells' 'sh scripts/shell.sh' 'shells initialization'
prompt 'install packages' 'sudo -E sh scripts/packages.sh' 'packages installation'

say -lt "$PROMPT_FACE" "System setup completed!
It's been a pleasure working with you, and I hope everything went fine.
Bye-Bye!"
