#!/usr/bin/env sh

# This script exports a shell function-based logging system.
#
# Messages are logged to stdout at one of these severity levels, here listed
# from the least to the most severe: debug, info, warning, error, silent. An
# instance of the logging system also has a severity level. Messages logged
# with a level less severe than the session's are not actually emitted. On the
# other hand, messages logged at a level more or equally severe than the
# session's are instead printed on stdout. For example, setting the session log
# level to "warning" and then logging a message at "info" level would produce
# no output. Conversely, logging a message at "error" level would print to
# stdout.
#
# The logging functions are in the form "log_<severity level>" (eg. log_info),
# plus an extra function called "log" that takes the log level as the first
# argument. The message can be passed as an argument, or read from stdin.
#
# The logging system exports also a helper function to parse a pair of
# arguments from CLI. These involve setting a value for the configuration
# options described below and the session logging level.
#
# The logging system can be configured to prefix every emitted message with
# the journald syslog levels prefix codes defined by systemd and available
# here: https://www.freedesktop.org/software/systemd/man/sd-daemon.html#.
#
# The logging system can produce colored output, by using shell escape codes.
# This behavior can either be configured directly, or automatically determined
# by only producing colored output when both stdout and stderr are connected to
# a tty.
#
# The logging system can prefix every emitted message with a tag containing the
# name of the message's severity level.

#######################################
# Internal constants
#######################################

# Logging levels
__LOGGING_LEVEL_DEBUG=40
__LOGGING_LEVEL_INFO=30
__LOGGING_LEVEL_WARNING=20
__LOGGING_LEVEL_ERROR=10
__LOGGING_LEVEL_SILENT=0

#######################################
# Internal state variables
#######################################

# Current logging level as a number. Log messages with a greater level than
# this will not be emitted
__LOGGING_LEVEL_CURRENT="$__LOGGING_LEVEL_SILENT"

# Journald prefixes settings. They control whether the logging output will be
# prefixed by the syslog levels prefix codes defined by systemd and available
# here: https://www.freedesktop.org/software/systemd/man/sd-daemon.html#.
# Meant to work in tandem with SyslogLevelPrefix=true in systemd units.
__LOGGING_JOURNALD_PREFIXES='true'

# Tag settings. They control whether the emitted log messages are prefixed by a
# tag indicating their level.
__LOGGING_TAG='true'

# Colored output settings. They control whether the logging output will be
# colored or not, via shell escape codes.
#
# The default is set later on by detecting whether the stdout and stderr are
# piped to a tty
__LOGGING_COLOR=''

#######################################
# Internal functions
#######################################

# This function does the heavy lifting of logging messages. This includes:
#   - Determining whether the log message should be emitted
#   - Retrieving the message from a parameter or from stdin
#
# Arguments;
#   - $1: The message log level
#   - $2: The message tag
__logging_print() {
    __LOG_MSG_LEVEL="$1"
    __LOG_MSG_TAG=${2:-''}

    __LOG_MSG_FORMAT="$__LOG_MSG_TAG%s\n"

    [ "$__LOGGING_LEVEL_CURRENT" -ge "$__LOG_MSG_LEVEL" ] && {
        if [ -n "$3" ]; then
            __LOG_MSG="$3"
            # shellcheck disable=2059
            printf "$__LOG_MSG_FORMAT" "$__LOG_MSG"
        else
            while read -r __LOG_MSG; do
                # shellcheck disable=2059
                printf "$__LOG_MSG_FORMAT" "$__LOG_MSG"
            done
        fi

        unset __LOG_MSG
    }

    unset __LOG_MSG_FORMAT __LOG_MSG_LEVEL __LOG_MSG_TAG
}

#######################################
# Configuration functions
#######################################

# This function is meant as a helper for handling logging-related
# CLI-arguments. This involves parsing and executing the corresponding action.
#
# It takes in a pair of arguments and attempts to parse them. If it succeeds,
# it returns the number of used arguments, by which the caller is meant to
# `shift`. If it fails, it returns 255.
#
# The accepted argument pairs are:
#   - '--<log level>': sets the session log level. The log level must be valid
#   - '--color' - any value accepted by logging_set_color: configures the
#       colored output settings
#   - '--journald' - any value accepted by logging_set_journald: configures the
#       journald prefixes settings
#   - '--log-level' - any value accepted by logging_set_level: sets the session
#       loggin level
#   - '--tag' - any value accepted by logging_set_tag: configures the tag
#       settings
#
# Arguments:
#   - $1: The first CLI argument. Normally the argument name, or "label"
#   - $2: The second CLI argument. Normally the value
# Return:
#   - The number of consumed arguments if the parsing was successful
#   - 255 if an error occurred while parsing
logging_parse_arg() {
    case "$(echo "$1" | tr '[:upper:]' '[:lower:]')" in
        '--color')
            logging_set_color "$2" || return 255
            return 2
            ;;

        '--journald')
            logging_set_journald "$2" || return 255
            return 2
            ;;

        '--log-level')
            logging_set_level "$2" || return 255
            return 2
            ;;

        '--tag')
            logging_set_tag "$2" || return 255
            return 2
            ;;

        *)
            logging_set_level "$1" 'false' || return 0
            return 1
            ;;
    esac
}

# This function sets the colored output settings. These control whether the
# logging output will be colored or not, via shell escape codes.
#
# In addition to boolean modes, an automatic mode is also supported, which will
# produce colored output only when both stdout and stderr are connected to a
# tty.
#
# This function returns 1 in case the provided value is not supported.
#
# The following value are accepted as input. Input is case-insensitive.
#   - on, true, yes, y      -->     Sets the output to be colored
#   - off, false, no, n     -->     Sets the output not to be colored
#   - auto, a               -->     Sets the automatic mode (color only if both
#                                   stdout and stderr are connected to a tty)
# Arguments:
#   - $1: The value to set the colored output settings to. Must be one of those
#         listed above
logging_set_color() {
    case "$(echo "$1" | tr '[:upper:]' '[:lower:]')" in
        'on'|'true'|'yes'|'y')
            __LOGGING_COLOR='true'
            ;;
        'off'|'false'|'no'|'n')
            __LOGGING_COLOR='false'
            ;;
        'auto'|'a')
            if [ -t 1 ] && [ -t 2 ]; then
                __LOGGING_COLOR='true'
            else
                __LOGGING_COLOR='false'
            fi
            ;;
        *)
            echo >&2 "Unsupported logger color value: $1"
            return 1
            ;;
    esac
}
# This is where we set the default value for colored output settings
logging_set_color 'auto'

# This function sets the journald prefixes settings. These control whether the
# logging output will be prefixed by the syslog levels prefix codes defined
# by systemd and available here: https://www.freedesktop.org/software/systemd/man/sd-daemon.html#.
# Meant to work in tandem with SyslogLevelPrefix=true in systemd units.
#
# This function returns 1 in case the provided value is not supported.
#
# The following value are accepted as input. Input is case-insensitive.
#   - on, true, yes, y      -->     Sets the output to be prefixed by systemd
#                                   syslog level prefixes
#   - off, false, no, n     -->     Sets the output not to be prefixed by
#                                   systemd syslog level prefixes
#
# Arguments:
#   - $1: The value to set the journald prefixes settings to. Must be one of
#         those listed above
logging_set_journald() {
    case "$(echo "$1" | tr '[:upper:]' '[:lower:]')" in
        'on'|'true'|'yes'|'y')
            __LOGGING_JOURNALD_PREFIXES='true'
            ;;
        'off'|'false'|'no'|'n')
            __LOGGING_JOURNALD_PREFIXES='false'
            ;;
        *)
            echo >&2 "Unsupported logger journald value: $1"
            return 1
            ;;
    esac
}

# This function sets the logging level for the active session. This controls
# which log messages will be emitted. These are the logging levels, from the
# least to the most restrictive:
#   - debug
#   - info
#   - warning
#   - error
#   - silent
# Only messages with a logging level that is less or equally restrictive than
# the value passed to this function will be emitted. For example, if the
# logging level is set to "warning", only messages with a logging level of
# "warning", "error" and "silent" will be emitted, while the ones with logging
# level of "info" and "debug" will be not.
#
# This function returns 1 in case the provided value is not supported.
#
# The accepted input values are the logging levels listed above, optionally
# prefixed with two dashes (eg. --error). Input is case-insensitive.
#
# Arguments:
#   - $1: The value to set the log level to. Must be one of those listed above.
#   - $2: Whether to output error messages. Optional, defaults to true.
logging_set_level() {
    case "$(echo "$1" | tr '[:upper:]' '[:lower:]')" in
        '--debug'|'debug')
            __LOGGING_LEVEL_CURRENT="$__LOGGING_LEVEL_DEBUG"
            ;;
        '--info'|'info')
            __LOGGING_LEVEL_CURRENT="$__LOGGING_LEVEL_INFO"
            ;;
        '--warning'|'warning')
            __LOGGING_LEVEL_CURRENT="$__LOGGING_LEVEL_WARNING"
            ;;
        '--error'|'error')
            __LOGGING_LEVEL_CURRENT="$__LOGGING_LEVEL_ERROR"
            ;;
        '--silent'|'silent')
            __LOGGING_LEVEL_CURRENT="$__LOGGING_LEVEL_SILENT"
            ;;
        *)
            [ "${2:-true}" = 'true' ] && echo >&2 "Unsupported log level: $1"
            return 1
            ;;
    esac
}

# This function sets the tag settings. These control whether the emitted log
# messages are prefixed by a tag indicating their level (eg. [DEBUG]).
#
# This function returns 1 in case the provided value is not supported.
#
# The following value are accepted as input. Input is case-insensitive.
#   - on, true, yes, y      -->     Sets messages to be prefixed by their
#                                   logging level tag
#   - off, false, no, n     -->     Sets messages not to be prefixed by their
#                                   logging level tag
#
# Arguments:
#   - $1: The value to set the tag settings to. Must be one of those listed
#         above
logging_set_tag() {
    case "$(echo "$1" | tr '[:upper:]' '[:lower:]')" in
        'on'|'true'|'yes'|'y')
            __LOGGING_TAG='true'
            ;;
        'off'|'false'|'no'|'n')
            __LOGGING_TAG='false'
            ;;
        *)
            echo >&2 "Unsupported logger tag value: $1"
            return 1
            ;;
    esac
}

#######################################
# Logging functions
#######################################

# This function logs a message of "debug" level. The message can either be
# passed as an argument, or be read by stdin.
#
# Arguments:
#   - $1: The message to be logged. Optional.
log_debug() {
    [ "$__LOGGING_TAG" = 'true' ] && {
        __LOG_TAG_DEBUG='[DEBUG] '
    }

    [ "$__LOGGING_COLOR" = 'true' ] && {
        __LOG_TAG_DEBUG="\e[2m$__LOG_TAG_DEBUG\e[0m"
    }

    [ "$__LOGGING_JOURNALD_PREFIXES" = 'true' ] && {
        __LOG_TAG_DEBUG="<7>$__LOG_TAG_DEBUG"
    }

    __logging_print "$__LOGGING_LEVEL_DEBUG" "$__LOG_TAG_DEBUG" "$1"

    unset __LOG_TAG_DEBUG
}

# This function logs a message of "info" level. The message can either be
# passed as an argument, or be read by stdin.
#
# Arguments:
#   - $1: The message to be logged. Optional.
log_info() {
    [ "$__LOGGING_TAG" = 'true' ] && {
        __LOG_TAG_INFO='[INFO] '
    }

    [ "$__LOGGING_COLOR" = 'true' ] && {
        __LOG_TAG_INFO="\e[32m$__LOG_TAG_INFO\e[0m"
    }

    [ "$__LOGGING_JOURNALD_PREFIXES" = 'true' ] && {
        __LOG_TAG_INFO="<6>$__LOG_TAG_INFO"
    }

    __logging_print "$__LOGGING_LEVEL_INFO" "$__LOG_TAG_INFO" "$1"

    unset __LOG_TAG_INFO
}

# This function logs a message of "warning" level. The message can either be
# passed as an argument, or be read by stdin.
#
# Arguments:
#   - $1: The message to be logged. Optional.
log_warning() {
    [ "$__LOGGING_TAG" = 'true' ] && {
        __LOG_TAG_WARNING='[WARNING] '
    }

    [ "$__LOGGING_COLOR" = 'true' ] && {
        __LOG_TAG_WARNING="\e[33m$__LOG_TAG_WARNING\e[0m"
    }

    [ "$__LOGGING_JOURNALD_PREFIXES" = 'true' ] && {
        __LOG_TAG_WARNING="<4>$__LOG_TAG_WARNING"
    }

    __logging_print "$__LOGGING_LEVEL_WARNING" "$__LOG_TAG_WARNING" "$1"

    unset __LOG_TAG_WARNING
}

# This function logs a message of "error" level. The message can either be
# passed as an argument, or be read by stdin.
#
# Arguments:
#   - $1: The message to be logged. Optional.
log_error() {
    [ "$__LOGGING_TAG" = 'true' ] && {
        __LOG_TAG_ERROR='[ERROR] '
    }

    [ "$__LOGGING_COLOR" = 'true' ] && {
        __LOG_TAG_ERROR="\e[31m$__LOG_TAG_ERROR\e[0m"
    }

    [ "$__LOGGING_JOURNALD_PREFIXES" = 'true' ] && {
        __LOG_TAG_ERROR="<3>$__LOG_TAG_ERROR"
    }

    __logging_print "$__LOGGING_LEVEL_ERROR" "$__LOG_TAG_ERROR" "$1"

    unset __LOG_TAG_ERROR
}

# This function logs a message of "silent" level, which means it does nothing.
# It is defined mostly for consistency. The message can either be passed as an
# argument, or be read by stdin.
#
# Arguments:
#   - $1: The message to be logged. Optional.
log_silent() {
    return 0
}

# This function logs a message with the provided logging level. The level must
# be one of the supported ones, that is:
#   - debug
#   - info
#   - warning
#   - error
#   - silent
# The logging level input is case-insensitive. The message can either be passed
# as an argument, or be read by stdin.
#
# Arguments:
#   - $1: The logging level. Must be one of those listed above.
#   - $2: The message to be logged. Optional.
log() {
    case "$(echo "$1" | tr '[:upper:]' '[:lower:]')" in
        'debug')
            log_debug "$2"
            ;;
        'info')
            log_info "$2"
            ;;
        'warning')
            log_warning "$2"
            ;;
        'error')
            log_error "$2"
            ;;
        'silent')
            log_silent "$2"
            ;;
    esac
}
