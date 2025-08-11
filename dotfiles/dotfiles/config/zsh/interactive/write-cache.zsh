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

# This prevents piping stdout to log_error when stdout is redirected to a file
setopt nomultios

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
# Ensure zsh cache directory
########################################

[ -z "$ZCACHEDIR" ] && {
    log_error >&2 '$ZCACHEDIR not defined'
    exit 64
}

log_debug 'Create zsh cache directory'
mkdir --parents "$ZCACHEDIR"

#######################################
# fasd
#######################################

log_info 'Write fasd zsh cache'
fasd --init posix-alias zsh-hook zsh-ccomp zsh-ccomp-install zsh-wcomp \
    zsh-wcomp-install 2>&1 > "$ZCACHEDIR/fasd" | log_error >&2

#######################################
# thefuck
#######################################

log_info 'Write thefuck zsh shell cache'
env TF_SHELL='zsh' thefuck --alias 2>&1 > "$ZCACHEDIR/thefuck" \
    | log_error >&2

########################################
# Zygal theme
########################################

log_debug 'Find zygal init file'
ZYGAL_INIT="$(find "${XDG_DATA_HOME:-$HOME/.local/share}/sheldon" -type f \
    -path '*zygal/zsh/autoload.zsh')"

log_debug 'Source zygal-static function'
source "$ZYGAL_INIT"

log_info 'Write static zygal code'
source "$ZDOTDIR/interactive/plugins/dotfiles/zygal-conf.zsh"
zygal-static 2>&1 > "$ZCACHEDIR/zygal" | cut --delimiter ' ' --fields 1
