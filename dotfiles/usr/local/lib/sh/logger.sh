#!/usr/bin/env sh

# This script defines some logging utility functions

__LOGGING_DEBUG_LEVEL=40
__LOGGING_INFO_LEVEL=30
__LOGGING_WARNING_LEVEL=20
__LOGGING_ERROR_LEVEL=10
__LOGGING_SILENT_LEVEL=0

__LOGGING_CURRENT_LEVEL=0
__LOGGING_JOURNALD_PREFIXES='true'
__LOGGING_TAG='true'
__LOGGING_COLOR=''

__logging_print() {
    __LOG_TARGET_LEVEL="$1"
    __LOG_TAG=${2:-''}

    [ "$__LOGGING_CURRENT_LEVEL" -ge "$__LOG_TARGET_LEVEL" ] && {
        if [ -n "$3" ]; then
            __LOG_MSG="$3"
            echo "$__LOG_TAG$__LOG_MSG"
        else
            while read __LOG_MSG; do
                echo "$__LOG_TAG$__LOG_MSG"
            done
        fi

        unset __LOG_MSG
    }

    unset __LOG_TAG __LOG_TARGET_LEVEL
}

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
            logging_set_level "$1" || return 255
            return 1
            ;;
    esac
}

logging_set_level() {
    case "$(echo "$1" | tr '[:upper:]' '[:lower:]')" in
        '--debug'|'debug')
            __LOGGING_CURRENT_LEVEL="$__LOGGING_DEBUG_LEVEL"
            ;;
        '--info'|'info')
            __LOGGING_CURRENT_LEVEL="$__LOGGING_INFO_LEVEL"
            ;;
        '--warning'|'warning')
            __LOGGING_CURRENT_LEVEL="$__LOGGING_WARNING_LEVEL"
            ;;
        '--error'|'error')
            __LOGGING_CURRENT_LEVEL="$__LOGGING_ERROR_LEVEL"
            ;;
        '--silent'|'silent')
            __LOGGING_CURRENT_LEVEL="$__LOGGING_SILENT_LEVEL"
            ;;
        *)
            echo >&2 "Unsupported log level: $1"
            return 1
            ;;
    esac
}

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
logging_set_color 'auto'

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

    __logging_print "$__LOGGING_DEBUG_LEVEL" "$__LOG_TAG_DEBUG" "$1"

    unset __LOG_TAG_DEBUG
}

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

    __logging_print "$__LOGGING_INFO_LEVEL" "$__LOG_TAG_INFO" "$1"

    unset __LOG_TAG_INFO
}

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

    __logging_print "$__LOGGING_WARNING_LEVEL" "$__LOG_TAG_WARNING" "$1"

    unset __LOG_TAG_WARNING
}

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

    __logging_print "$__LOGGING_ERROR_LEVEL" "$__LOG_TAG_ERROR" "$1"

    unset __LOG_TAG_ERROR
}

log_silent() {
    return 0
}

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
