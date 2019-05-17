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
EXIT_NO=254
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

    $CMD > "$OUTPUT_LOG" 2>&1
    if [ $? -eq 0 ]; then
        printf "$OK_FACE Everything fine with $DESC! Hooray!\n"
        rm "$OUTPUT_LOG"
    else
        printf "$ERROR_FACE Something went wrong while $DESC.\n"
        inspect_error "$OUTPUT_LOG"
    fi

    unset CMD OUTPUT_LOG
}

goodbye() {
    printf "\n$SAD_FACE Saying goodbye early! Anything went wrong?\n"
    exit
}

inspect_error() {
    LOG_FILE="$1"

    printf "
      Do you want to see the output log? (The log has been saved to
      ${LOG_FILE})? "
    if read_answer; then
        less "$LOG_FILE"
    fi

    unset LOG_FILE
}

prompt() {
    PROMPT="$1"
    CMD="$2"
    DESC="$3"

    printf "\n$PROMPT_FACE $PROMPT? "
    if read_answer; then
        execute "$CMD" "$DESC"
    else
        printf "$PROMPT_FACE Skipping $DESC then.\n"
    fi

    unset PROMPT CMD
}

read_answer() {
    printf ' [y/n/q] '
    read ANSWER
    case "$(echo "$ANSWER" | tr '[:upper:]' '[:lower:]')" in
        n|no)
            return "$EXIT_NO"
            ;;

        q|quit)
            goodbye
            ;;

        y|yes)
            return "$EXIT_YES"
            ;;
    esac

}

#######################################
# Script
#######################################

trap goodbye INT TERM

printf "$PROMPT_FACE Hello, I'm your setup script!
      I'll guide you step-by-step through your system setup. I'll prompt you
      before each step, copy configuration files, execute commands, and report
      you output and errors when they occur.
      Good luck, and let's hope it all goes well!
"



prompt 'Do you want to install applications' 'echo 3' 'installing applications'
prompt 'Do you want to install applications' 'echo 3' 'installing applications'
prompt 'Do you want to install applications' 'false' 'installing applications'

printf "
$PROMPT_FACE System setup completed!
      It's been a pleasure working with you, and I hope everything went fine.
      Bye-Bye!
"
