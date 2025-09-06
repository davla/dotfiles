#!/usr/bin/env sh

# This script populates the POSIX shell cache for the plugins that have a cache
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
# Ensure POSIX shell cache directory
########################################

[ -z "$SCACHEDIR" ] && {
    # shellcheck disable=2016
    log_error >&2 '$SCACHEDIR not defined'
    exit 64
}

log_debug 'Create POSIX shell cache directory'
mkdir --parents "$SCACHEDIR"

#######################################
# fasd
#######################################

log_info 'Write fasd POSIX shell cache'
fasd --init posix-alias 2>&1 > "$SCACHEDIR/fasd" | log_error >&2

#######################################
# thefuck
#######################################

log_info 'Write thefuck POSIX shell cache'
( thefuck --alias & ) 2>&1 > "$SCACHEDIR/thefuck" | log_error >&2
