#!/usr/bin/env sh

# This script interactively sets up the whole system, one step at a time, by
# displaying various prompts at the user. This is done via a friendly and
# supportive bot assistnt, that is not ashamed of showing its feelings and
# facial expressions [^_^]. Each step outputs in a separate terminal buffer, as
# well as a log file. Steps can be skipped and repeated.
#
# Arguments:
#   - $1: The step to be executed. If not given, one will be prompted.
#   - $2+: Arguments for the "security" script.

. ./.dotfiles-env

########################################
# Variables
########################################

# All the available bot steps. In a variable so that we can check for validity
# when interactively prompting the user.
STEPS="custom-commands, dotdrop, environment, getty-login, graphical-login, \
hardware, i3, keyboard-layout, manual, network, packages, remote-access, \
repos, security, shells, startup, sway, system-tweaks, themes, timers, xfce"

# Colors
RESET_COLOR="$(printf '\e[0;0m')"

ERROR_COLOR="$(printf '\e[1;91m')"
OK_COLOR="$(printf '\e[1;92m')"
PROMPT_COLOR="$(printf '\e[1;93m')"
SAD_COLOR="$(printf '\e[1;96m')"

# Exit codes
EXIT_NO=253
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
MSG_WIDTH="${COLUMNS:-80}"
MSG_WIDTH=$(( MSG_WIDTH - $(printf '%s' "$INDENT" | wc --chars) ))
IN_ALTERNATE_BUFFER='false'

# Reset
SHELL="$(ps --no-headers --pid "$$" -o 'comm')"
USER="$(id --user --name)"

#######################################
# Input processing
#######################################

# Bot step to be executed
STEP="$1"
if [ -n "$STEP" ]; then
    shift
fi

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
    # The function is recursive, and not iterative, since read needs not to be
    # in a loop, as this would execute it in a subshell, that is with no stdin.

    say "$@"

    case "$(head --lines 1 | tr '[:upper:]' '[:lower:]')" in
        n|no)
            return "$EXIT_NO"
            ;;

        q|quit)
            # This sets $? for goodbye
            (exit 1)
            goodbye --trailing 1
            ;;

        y|yes)
            return "$EXIT_YES"
            ;;

        *)
            say --trailing 1 "$PROMPT_FACE" "Sorry, I didn't get it."
            ask "$@"
            # Need to return explicitly in order not to lose ask exit code: in
            # fact, the last command is the case statement, which overwrites
            # the exit code
            return
            ;;
    esac
}

# This function is meant to be used as a trap.
#
# It cleans up resources acquired at any point in the script, such as the
# terminal alternate buffer, named pipes and detached subprocesses.
cleanup() {
    [ "$IN_ALTERNATE_BUFFER" = 'true' ] && tput rmcup
    [ -n "$OUTPUT_LOG" ] && rm --force "$OUTPUT_LOG"
    [ -n "$CMD_PIPE" ] && rm --force "$CMD_PIPE"
    [ -n "$CMD_TEE_PID" ] && kill -s TERM "$CMD_TEE_PID" > /dev/null 2>&1
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
    EXECUTE__CMD="$1"
    EXECUTE__DESC="$2"

    OUTPUT_LOG="$(mktemp)"

    EXECUTE__RETRY='true'
    while [ "$EXECUTE__RETRY" = 'true' ]; do
        # `tput smcup` exits with an error if "alternate buffers" are not
        # supported by the terminal. In such case, we avoid changing the cursor
        # position, so that the previous output is not overwritten
        tput smcup && {
            IN_ALTERNATE_BUFFER='true'
            tput cup 0 0
        }

        # We can't just pipe the command to tee, as that would mask the
        # command's exit code.
        CMD_PIPE="$(mktemp --dry-run)"
        mkfifo "$CMD_PIPE"

        (tee "$OUTPUT_LOG" < "$CMD_PIPE") &
        CMD_TEE_PID="$!"

        sh -c "$EXECUTE__CMD" > "$CMD_PIPE" 2>&1
        EXECUTE__CMD_EXIT_CODE="$?"

        unset CMD_TEE_PID
        printf 'Press enter to continue'
        read -r ANSWER

        [ "$IN_ALTERNATE_BUFFER" = 'true' ] && {
            IN_ALTERNATE_BUFFER='false'
            tput rmcup
        }

        if [ "$EXECUTE__CMD_EXIT_CODE" -eq 0 ]; then
            ask "$OK_FACE" "Looks like everything went fine with the step to \
$EXECUTE__DESC! Hooray!
The log has been saved to $OUTPUT_LOG. $RETRY_PROMPT"
        else
            ask "$ERROR_FACE" "Looks like something went wrong with the step \
to $EXECUTE__DESC.
The log has been saved to $OUTPUT_LOG. $RETRY_PROMPT"
        fi

        # ask exit code, that is the user answer.
        case "$?" in
            "$EXIT_YES")
                EXECUTE__RETRY='true'
                ;;

            "$EXIT_NO")
                EXECUTE__RETRY='false'
                ;;

            *)  # Should never occur, hopefully an error message has already
                # been printed
                exit
                ;;
        esac
    done

    printf '\n'

    unset EXECUTE__CMD EXECUTE__CMD_EXIT_CODE EXECUTE__DESC EXECUTE__RETRY
}

# This function prints a message before exiting the script with the last exit
# code available before its call.
#
# Arguments:
#   - $1: Options for say tunctions (default: --leading 2 --trailing 1).
goodbye() {
    # This needs to be before positional parameter assignments, since they
    # would otherwise overwrite the exit code.
    GOODBYE__EXIT_CODE="$?"

    cleanup

    # shellcheck disable=SC2068
    say ${@:---leading 2 --trailing 1} "$SAD_FACE" \
        'Saying goodbye early! Anything went wrong?'
    exit "$GOODBYE__EXIT_CODE"
}

# This function prompts the user whether to execute a command. The command is
# executed or skipped based on the user answer.
#
# Arguments:
#   - $1: The command to be run.
#   - $2: The command description. It should preferrably be an imperative form.
prompt() {
    PROMPT__CMD="$1"
    PROMPT__DESC="$2"

    if ask "$PROMPT_FACE" "Do you want to $PROMPT__DESC? $CHOICES"; then
        execute "$PROMPT__CMD" "$PROMPT__DESC"
    else
        say --trailing 2 "$PROMPT_FACE" \
            "Skipping the step to $PROMPT__DESC then."
    fi

    unset PROMPT__CMD PROMPT__DESC
}

# This function prints a message as "said" by the bot, that is a face with a
# message next to it, indented so as to have empty space below the face. No
# trailing newline is printed by default.
#
# Arguments:
#   - --leading <count>|-L COUNT: Number of leading newlines to display.
#                                 Optional, defaults to none.
#   - --trailing <count>|-T COUNT: Number of trailing newlines to display.
#                                  Optional, defaults to none.
#   - $1: The face to be printed
#   - $2: The message to be printed
say() {
    SAY__FACE=''
    SAY__MSG=''
    SAY__LEADING_NEWLINES_COUNT=0
    SAY__TRAILING_NEWLINES_COUNT=0
    while [ $# -gt 0 ]; do
        case "$1" in
            '--leading'|'-L')
                SAY__LEADING_NEWLINES_COUNT="$2"
                shift
                ;;

            '--trailing'|'-T')
                SAY__TRAILING_NEWLINES_COUNT="$2"
                shift
                ;;

            *)
                if [ -z "$SAY__FACE" ]; then
                    SAY__FACE="$1"
                else
                    SAY__MSG="$1"
                fi
                ;;

        esac
        shift
    done

    seq 1 "$SAY__LEADING_NEWLINES_COUNT" \
        | xargs --no-run-if-empty printf '\n%.0s'
    # sed prepends the first line with the bot face and the following ones with
    # the indent
    printf '%s' "$SAY__MSG" | fold --spaces --width "$MSG_WIDTH" \
        | sed "1 s/^/$SAY__FACE / ; 2,$ s/^/$INDENT/"
    seq 1 "$SAY__TRAILING_NEWLINES_COUNT" \
        | xargs --no-run-if-empty printf '\n%.0s'

    unset SAY__FACE SAY__LEADING_NEWLINES_COUNT SAY__MSG \
        SAY__TRAILING_NEWLINES_COUNT
}

#######################################
# Intro
#######################################

trap goodbye INT HUP TERM

say --trailing 2 "$PROMPT_FACE" "Hello, I'm your setup script!
I'll guide you step-by-step through your system setup. I'll prompt you before \
each step, copy configuration files, execute commands, and report you output \
and errors when they occur.
Good luck, and let's hope it all goes well!"

#######################################
# Steps
#######################################

# If a step name wasn't supplied as a cli argument, prompting the user for one
[ -z "$STEP" ] && {
    if ask "$PROMPT_FACE" "Do you want to execute a specific step? $CHOICES"
    then
        say "$PROMPT_FACE" "These are the available steps:
$STEPS: "
            read -r STEP
    else
        STEP='all'
        say --trailing 2 "$PROMPT_FACE" "I will guide you through all the \
steps then. I'll prompt you before each one, so you can skip the \
steps you don't want to run"
    fi
}

# At this point, $STEP is either provided by the cli, or interactively entered
# by the user, or programmatically set to 'all'. We can therefore proceed to
# valiation. A valid step is either 'all' or one of the listed steps.
while [ "$STEP" != 'all' ] && ! echo "$STEPS" | grep --quiet "$STEP"; do
    say --trailing 1 "$PROMPT_FACE" "Sorry, I don't know the '$STEP' step."
    say "$PROMPT_FACE" "These are the available steps:
$STEPS: "
    read -r STEP
    printf '\n'
done

# Normalizing script name
STEP="$(echo "${STEP}" | tr '[:upper:]' '[:lower:]')"

# The command used to execute the step. When executing all steps, a prompt is
# displayed to allow the user to skip steps interactively
[ "$STEP" = 'all' ] && STEP_RUNNER='prompt' || STEP_RUNNER='execute'

case "$STEP" in
    'dotdrop'|'all')
        # Dotdrop setup - first as anything else depends on it.
        $STEP_RUNNER "sh -e bot-steps/dotdrop.sh $PWD" 'set dotdrop up'
        ;;
esac
case "$STEP" in
    'custom-commands'|'all')
        # Custom commands - they are used by other steps.
        $STEP_RUNNER "sudo --set-home --preserve-env=$DOTFILES_ENV_VARS \
            uv run dotdrop install --cfg dotfiles/config-root.yaml \
            --profile commands" 'install your custom commands'
        ;;
esac
case "$STEP" in
    'environment'|'all')
        # Shell environment - environment variables are used in other steps.
        $STEP_RUNNER 'dotdrop -U root install -p environment' \
            'set up the environment'
        ;;
esac
case "$STEP" in
    'packages'|'all')
        # Packages installation - they make commands available for other
        # steps.
        $STEP_RUNNER "sudo sh -e bot-steps/$DISTRO/packages.sh $USER" \
            'packages installation'
        ;;
esac
case "$STEP" in
    'manual'|'all')
        # Manual applications install
        $STEP_RUNNER "sudo sh -e bot-steps/manually.sh" \
            'install manually managed applications'
        ;;
esac
case "$STEP" in
    'system-tweaks'|'all')
        # System-wide configuration, sucha as sudo and locales
        $STEP_RUNNER 'dotdrop -U root install -p system-tweaks' \
            'install system-wide configuration'
        ;;
esac
case "$STEP" in
    'getty-login'|'all')
        # Getty login manager
        $STEP_RUNNER 'dotdrop -U root install -p getty-login' \
            'set up getty login'
        ;;
esac
case "$STEP" in
    'graphical-login'|'all')
        # Graphical login manager
        $STEP_RUNNER 'sudo sh -e bot-steps/graphical-login.sh' \
            'install a graphical login manager'
        ;;
esac
case "$STEP" in
    'i3'|'all')
        # i3
        $STEP_RUNNER 'sh -e bot-steps/i3.sh' 'install i3'
        ;;
esac
case "$STEP" in
    'sway'|'all')
        # i3
        $STEP_RUNNER 'sh -e bot-steps/sway.sh' 'install sway'
        ;;
esac
case "$STEP" in
    'xfce'|'all')
        # Xfce
        $STEP_RUNNER 'sh -e bot-steps/xfce.sh' 'install Xfce'
        ;;
esac
case "$STEP" in
    'keyboard-layout'|'all')
        # Keyboard
        $STEP_RUNNER 'dotdrop -U root install -p xkb' 'add keyboard layouts'
        ;;
esac
case "$STEP" in
    'startup'|'all')
        # Startup jobs
        $STEP_RUNNER 'sh -e bot-steps/startup.sh' 'set up startup jobs'
        ;;
esac
case "$STEP" in
    'timers'|'all')
        # Systemd timers
        $STEP_RUNNER 'sh -e bot-steps/timers.sh' 'set up systemd timers'
        ;;
esac
case "$STEP" in
    'network'|'all')
        # Network
        $STEP_RUNNER "sudo sh -e bot-steps/network.sh" 'set up the network'
        ;;
esac
case "$STEP" in
    'hardware'|'all')
        # Hardware
        $STEP_RUNNER "sudo sh -e bot-steps/hardware.sh $USER" \
            'apply hardware tweaks'
        ;;
esac
case "$STEP" in
    'security'|'all')
        # SSH and GPG keys
        $STEP_RUNNER "sh -e bot-steps/security.sh $*" \
            'generate SSH and GPG keys'
        ;;
esac
case "$STEP" in
    'remote-access'|'all')
        # Remote access configuration, such as ssh and nfs
        $STEP_RUNNER 'sudo sh -e bot-steps/remote-access.sh' \
            'set up remote access'
esac
case "$STEP" in
    'shells'|'all')
        # Shells setup
        $STEP_RUNNER 'sh -e bot-steps/shell.sh' 'initialize the shells'
        ;;
esac
case "$STEP" in
    'themes'|'all')
        # Themes
        $STEP_RUNNER 'sudo sh -e bot-steps/aesthetics.sh' \
            'install cursor, desktop and icon themes'
        ;;
esac
case "$STEP" in
    'repos'|'all')
        # Repositories
        $STEP_RUNNER 'sh -e bot-steps/repos.sh' \
            'initialize your coding workspace'
        ;;
esac

#######################################
# Outro
#######################################

say --trailing 1 "$PROMPT_FACE" "System setup completed!
It's been a pleasure working with you, and I hope everything went fine.
Bye-Bye!"

cleanup
