#!/usr/bin/env sh

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

#######################################
# Functions
#######################################

execute() {
    CMD="$1"
    DESC="$2"

    OUTPUT_LOG=$(mktemp)
    $SHELL -c "$CMD" > "$OUTPUT_LOG" 2>&1
    if [ $? -eq 0 ]; then
        say -tt "$OK_FACE Everything fine with $DESC! Hooray!"
        rm "$OUTPUT_LOG"
    else
        say -t "$ERROR_FACE Something went wrong while $DESC."
        inspect_error "$OUTPUT_LOG"
    fi

    unset CMD OUTPUT_LOG
}

goodbye() {
    SAY_OPTS="${1:-llt}"
    say -$SAY_OPTS "$SAD_FACE Saying goodbye early! Anything went wrong?"
    exit
}

inspect_error() {
    LOG_FILE="$1"

    say "      Do you want to see the output log? (The log has been saved to \
${LOG_FILE})?"
    if read_answer; then
        less "$LOG_FILE"
    fi
    printf '\n'

    unset LOG_FILE
}

prompt() {
    PROMPT="$1"
    CMD="$2"
    DESC="$3"

    say "$PROMPT_FACE Do you want to $PROMPT?"
    if read_answer; then
        execute "$CMD" "$DESC"
    else
        say -tt "$PROMPT_FACE Skipping $DESC then."
    fi

    unset PROMPT CMD
}

read_answer() {
    say ' [y/n/q] '
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
    MSG="$1"

    FULL_WIDTH="$(printf "$MSG" | fold -sw 79)"
    INDENTED_WIDTH="$(printf "$FULL_WIDTH" | tail -n +2 | tr '\n' ' ' \
        | fold -sw 73)"

    printf "$LEADING_NEWLINES"
    printf "$FULL_WIDTH" | head -n 1
    [ -n "$INDENTED_WIDTH" ] && {
        printf "$INDENTED_WIDTH" | head -n -1 | awk '{print "      " $0}'
        printf "$INDENTED_WIDTH" | tail -n 1 | xargs -0 printf '      %s'
    }
    printf "$TRAILING_NEWLINES"

    unset MSG FULL_WIDTH INDENTED_WIDTH OPTION LEADING_NEWLINES
    unset TRAILING_NEWLINES
}

#######################################
# Script
#######################################

trap goodbye INT TERM

say -tt "$PROMPT_FACE Hello, I'm your setup script!
I'll guide you step-by-step through your system setup. I'll prompt you before \
each step, copy configuration files, execute commands, and report you output \
and errors when they occur.
Good luck, and let's hope it all goes well!"

prompt 'set dotdrop up' 'sh scripts/dotdrop.sh ./dotfiles' \
    'dotdrop setup'
prompt 'install your custom commands' 'sudo sh custom-commands/install.sh' \
    'custom commands installation'
prompt 'initialize the shells' 'sh scripts/shell.sh' 'shells initialization'

say -t "$PROMPT_FACE System setup completed!
It's been a pleasure working with you, and I hope everything went fine.
Bye-Bye!"
