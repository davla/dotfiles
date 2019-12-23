#!/usr/bin/env sh

# This script interactively sets up the whole system, one step at a time, by
# displaying various prompts at the user. This is done via a friendly and
# supportive bot assistnt, that is not ashamed of showing its feelings and
# facial expressions [^_^]. Each step outputs in a separate terminal buffer, as
# well as a log file. Steps can be skipped and repeated.
#
# Arguments:
#   - $1: The terminal width, used when wrapping the bot's messages. Defaults
#         to $COLUMNS and then to 80.

. ./.env

#######################################
# Input processing
#######################################

MSG_WIDTH="${1:-$COLUMNS}"

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
ERROR_FACE="${ERROR_COLOR}[>.<]${RESET_COLOR}"
OK_FACE="${OK_COLOR}[°o°]${RESET_COLOR}"
PROMPT_FACE="${PROMPT_COLOR}[^_^]${RESET_COLOR}"
SAD_FACE="${SAD_COLOR}[ToT]${RESET_COLOR}"

# Texts
CHOICES='[y/n/q] '
INDENT='      '
RETRY_PROMPT="Do you want to retry? $CHOICES"

# Misc
MSG_WIDTH="${MSG_WIDTH:-80}"
MSG_WIDTH=$(( MSG_WIDTH - $(printf "$INDENT" | wc -m) ))
IN_ALTERNATE_BUFFER='false'

# Reset
SHELL="$(ps --no-headers -p "$$" -o 'comm')"
USER="$(id -un)"

#######################################
# Functions
#######################################

# This function asks the user the given question.
#
# Each answer has a different exit code. It accepts 'yes', 'no' and 'quit',
# case intensitively and both extended and first-letter only. Any other answer
# is considered invalid, and the question is asked until a valid answer is
# given.
#
# Arguments:
#   - $@: Same arguments as say
ask() {
    # THe function is recursice, and not iterative, since read needs not to be
    # in a loop, as this would execite it in a subshell, that is with no stdin.

    say "$@"

    read ANSWER

    # Each case unsets ANSWER as it ternimates with a return. Saving the exit
    # code in a variable and returing it wouldn't help, as such variable
    # cannot be unset after it's used.
    case "$(echo "$ANSWER" | tr '[:upper:]' '[:lower:]')" in
        n|no)
            unset ANSWER
            return "$EXIT_NO"
            ;;

        q|quit)
            unset ANSWER
            # This sets $? for goodbye
            (exit 1)
            goodbye -t
            ;;

        y|yes)
            unset ANSWER
            return "$EXIT_YES"
            ;;

        *)
            unset ANSWER
            say -t "$PROMPT_FACE" "Sorry, I didn't get it."
            ask "$@"
            # Need to return explicitly in order not to lose ask exit code: in
            # fact, the last command is the case statement, that overwrites
            # the exit code
            return
            ;;
    esac
}

# This function executes a command.
#
# It displays the command output in a separate screen buffer, waiting for user
# input to restore the previous buffer. After the command execution, its
# failure/success is reported, alongside a prompt for re-execution. The output
# is also saved to a temporary log file, deleted only after the user chooses
# not to repeat execution. The log file is overwritten at every execution.
#
# Arguments:
#   - $1: The command to be executed.
#   - $1: Description of the command, to be used for failure/success report.
execute() {
    CMD="$1"
    DESC="$2"

    OUTPUT_LOG=$(mktemp)

    RETRY='true'
    while [ "$RETRY" = 'true' ]; do
        tput smcup
        tput cup 0 0
        IN_ALTERNATE_BUFFER='true'

        # This is executed in the background: stdin is detatched, while stdout
        # and stderr are shared with this script (likely connected to a tty).
        tail -f "$OUTPUT_LOG" &

        $SHELL -ec "$CMD" > "$OUTPUT_LOG" 2>&1
        CMD_EXIT="$?"
        printf 'Press enter to continue'
        read ANSWER

        # Killng tail, as the command is no longer writing to the file.
        kill "$!"

        tput rmcup
        IN_ALTERNATE_BUFFER='false'

        if [ "$CMD_EXIT" -eq 0 ]; then
            ask "$OK_FACE" "Looks like everything went fine with $DESC! Hooray!
The log has been saved to $OUTPUT_LOG. $RETRY_PROMPT"
        else
            ask "$ERROR_FACE" "Looks like something went wrong with $DESC.
The log has been saved to $OUTPUT_LOG. $RETRY_PROMPT"
        fi

        # ask exit code, that is the user answer.
        case "$?" in
            "$EXIT_YES")
                RETRY='true'
                ;;

            "$EXIT_NO")
                RETRY='false'
                ;;

            *)  # Should never occur, hopefully an error message has already
                # been printed
                exit
                ;;
        esac
    done

    printf '\n'
    rm $OUTPUT_LOG

    unset CMD CMD_EXIT DESC OUTPUT_LOG RETRY
}

# This function prints a message before exiting the script with the last exit
# code available before its call.
#
# Arguments:
#   - $1: Options for say tunctions (default: -llt).
goodbye() {
    # This needs to be before positional parameter assignments, since they
    # would otherwise overwrite the exit code.
    EXIT_CODE="$?"

    # This is used as a signal handler, the alternate buffer might be active
    [ "$IN_ALTERNATE_BUFFER" = 'true' ] && tput rmcup

    SAY_OPTS="${1:--llt}"

    say "$SAY_OPTS" "$SAD_FACE" "Saying goodbye early! Anything went wrong?"
    exit "$EXIT_CODE"
}

# This function prompts the user whether to execute a command. The command is
# executed or skipped based on the user answer.
#
# Arguments:
#   - $1: Text to prompt the user with. It is appended to the string
#         "Do you want to", and it needs not to include the question mark and
#         the answer choices.
#   - $2: The command to be run.
#   - $3: The command descrption, suitable for an affirmative sentence.
prompt() {
    PROMPT="$1"
    CMD="$2"
    DESC="$3"

    if ask "$PROMPT_FACE" "Do you want to $PROMPT? $CHOICES"; then
        execute "$CMD" "$DESC"
    else
        say -tt "$PROMPT_FACE" "Skipping $DESC then."
    fi

    unset PROMPT CMD DESC
}

# This function prints a message as "said" by the bot, that is a face with a
# message next to it, indented so as to have empty space below the face. No
# trailing newline is printed by default.
#
# Arguments:
#   - -l: Flag, adds a leading newline. Can be specified multiple times,
#         to add more than one leading newline.
#   - -t: Flag, adds a trailing newline. Can be specified multiple times,
#         to add more than one trailing newline.
#   - $1: The face to be printed
#   - $2: The message to be printed
say() {
    # OPTIND needs to be reset to 0 every time. This is POSIX shell, local
    # variables don't exist. Unsetting it crashes the shell.
    OPTIND=0

    # These variables contain the actual newlines, not just counters.
    LEADING_NEWLINES=''
    TRAILING_NEWLINES=''
    while getopts 'lt' OPTION; do
        case "$OPTION" in
            'l')
                # Adding the newline itself
                LEADING_NEWLINES="$LEADING_NEWLINES\n"
                ;;

            't')
                # Adding the newline itself
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

    # Lines from the second onwards need to be separated, as the first one
    # doesn't need indentation.
    TAIL_LINES="$(printf "$MSG" | tail -n +2)"

    printf "$LEADING_NEWLINES"
    printf "$FACE"

    # The first line is printed with a one space indentation.
    printf "$MSG" | head -n 1 | xargs -0 printf ' %s'

    [ -n "$TAIL_LINES" ] && {
        # awk adds a newline, so it cannot be used on the last line, as we
        # don't want any trailing newline by default
        printf "$TAIL_LINES" | head -n -1 | awk "{print \"$INDENT\" \$0}"

        # Using xargs -0 and printf prevents a newline from being printed.
        printf "$TAIL_LINES" | tail -n 1 | xargs -0 printf "$INDENT%s"
    }
    printf "$TRAILING_NEWLINES"

    unset FACE LEADING_NEWLINES MSG OPTION TAIL_LINES TRAILING_NEWLINES
}

#######################################
# Intro
#######################################

trap goodbye INT TERM

say -tt "$PROMPT_FACE" "Hello, I'm your setup script!
I'll guide you step-by-step through your system setup. I'll prompt you before \
each step, copy configuration files, execute commands, and report you output \
and errors when they occur.
Good luck, and let's hope it all goes well!"

#######################################
# Steps
#######################################

# Dotdrop setup - first as anything else depends on it.
prompt 'set dotdrop up' 'sh -e scripts/dotdrop.sh ./dotfiles' 'dotdrop setup'

# Custom commands - they are used by other scripts.
prompt 'install your custom commands' 'sudo sh -e custom-commands/install.sh' \
    'custom commands installation'

# Shell environment - environment variables are used in other scripts.
prompt 'setup the environment' 'dotdrop -U root install -p environment' \
    'setting up the environment'

# Packages installation - they make commands available for other scripts.
prompt 'install packages' "sudo sh -e scripts/packages.sh $USER" \
    'packages installation'

# Manual applications install
prompt 'install manually managed applications' \
    "sudo sh -e -l scripts/manually.sh $USER" \
    'manually managed applications installation'

# Locales
prompt 'configure locales' 'dotdrop -U root install -p locales' \
    'configuring locales'

# Keyboard
prompt 'add keyboard layouts' 'dotdrop -U root install -p xkb' \
    'adding keyboard layouts'

# Network
prompt 'set up network tricks' 'sudo sh -e scripts/network.sh' \
    'setting up network tricks'

# Startup jobs
prompt 'set up startup jobs' 'sh -e scripts/startup.sh' \
    'setting up startup jobs'

# Cron & anacron jobs
prompt 'set up (ana)cron jobs' 'dotdrop -U both install -p cron' \
    'setting up (ana)cron jobs'

# PolicyKit
prompt 'configure PolicyKit' 'sudo -E dotdrop install -p polkit' \
    'configuring PolicyKit'

# SSH and GPG keys
prompt 'generate SSH and GPG keys' 'sh -e scripts/security.sh' \
    'SSH and GPG keys generation'

# Shells setup
prompt 'initialize the shells' 'sh -e scripts/shell.sh' 'shells initialization'

# Graphical login manager
prompt 'install a graphical login manager' \
    'sudo sh -e scripts/graphical-login.sh' \
    'installing a graphical login manager'

# Themes
prompt 'install cursor, desktop and icon themes' \
    'sh -e scripts/aesthetics.sh' \
    'cursor, desktop and icon themes installation'

# i3
prompt 'install i3' 'sh -e scripts/i3.sh' 'installing i3'

# Xfce
prompt 'install Xfce' 'sh -e scripts/xfce.sh' 'installing Xfce'

# Android
prompt 'install Android SDK' "sudo sh -e scripts/android.sh $USER" \
    'Android SDK installation'

#######################################
# Outro
#######################################

say -t "$PROMPT_FACE" "System setup completed!
It's been a pleasure working with you, and I hope everything went fine.
Bye-Bye!"
