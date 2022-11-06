#!/usr/bin/env zsh

# This script populates the zsh cache for the plugins that have a cache
# (fasd, thefuck, zygal).
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
# Environment validation
########################################

[ -z "$ZDOTDIR" ] && {
    log_error >&2 '$ZDOTDIR not defined'
    exit 64
}

# This prevents piping stdout to log_error when stdout is redirected to a file
setopt nomultios

#######################################
# fasd
#######################################

log_info 'Write fasd zsh cache'
fasd --init posix-alias zsh-hook zsh-ccomp zsh-ccomp-install zsh-wcomp \
    zsh-wcomp-install 2>&1 > "$ZDOTDIR/cache/fasd" | log_error >&2

#######################################
# thefuck
#######################################

log_info 'Write thefuck zsh shell cache'
env TF_SHELL='zsh' thefuck --alias 2>&1 > "$ZDOTDIR/cache/thefuck" \
    | log_error >&2

########################################
# Zygal theme
########################################

log_debug 'Source zygal-static function'
source <(antibody init)
antibody bundle < "$ZDOTDIR/interactive/theme/dotfiles/themes.list"

log_info 'Write static zygal code'
source "$ZDOTDIR/interactive/theme/dotfiles/zygal-conf.zsh"
zygal-static 2>&1 > "$ZDOTDIR/cache/zygal" | cut -f 1 -d ' '
