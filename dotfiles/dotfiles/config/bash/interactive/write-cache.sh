#!/usr/bin/env bash

# This script populates the bash cache for the plugins that have a cache
# (fasd, thefuck).
#
# The command-line options are the ones used for logging. For detailed info,
# check the source code at {{@@ logger_path @@}}. Here a quick summary:
#   - --<log level>: sets the session log level. The log level must be valid
#   - --color <on/off/auto>: configures the colored output settings
#   - --journald <on/off>: configures the journald prefixes settings
#   - --log-level <log level>: sets the session loggin level
#   - --tag <on/off>: configures the tag settings
#
# {{@@ header() @@}}

#######################################
# Libraries includes
#######################################

. "{{@@ logger_path @@}}"

#######################################
# Input processing
#######################################

while [ "$#" -gt 0 ]; do
    logging_parse_arg "$1" "$2"
    case "$?" in
        1)
            shift 1
            ;;

        2)
            shift 2
            ;;

        255)
            exit 255
            ;;
    esac
done

########################################
# Ensure bash cache directory
########################################

[ -z "$BCACHEDIR" ] && {
    # shellcheck disable=2016
    log_error >&2 '$BCACHEDIR not defined'
    exit 64
}

log_debug 'Create bash cache directory'
mkdir --parents "$BCACHEDIR"

#######################################
# fasd
#######################################

log_info 'Write fasd bash cache'
fasd --init bash-hook bash-ccomp bash-ccomp-install posix-alias 2>&1 \
    > "$BCACHEDIR/fasd" | log_error >&2

#######################################
# thefuck
#######################################

log_info 'Write thefuck bash shell cache'
env TF_SHELL='bash' thefuck --alias 2>&1 > "$BCACHEDIR/thefuck" \
    | log_error >&2
