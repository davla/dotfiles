#!/usr/bin/env sh

# This script configures and loads POSIX shell plugins and tools

#######################################
# asdf
#######################################

[ "$(ps --no-headings -p "$$" -o 'comm')" != 'sh' ] && {
    export ASDF_PATH='/opt/asdf-vm'
    export ASDF_CONFIG_PATH="$ASDF_PATH/etc"
    export ASDF_CONFIG_FILE="$ASDF_CONFIG_PATH/.asdfrc"
    export ASDF_DATA_DIR="$ASDF_PATH/data"
    export ASDF_DEFAULT_TOOL_VERSIONS_FILENAME=\
"$ASDF_CONFIG_PATH/.tool-versions"

    . "$ASDF_PATH/asdf.sh"
}

#######################################
# exa
#######################################

EXA_COLORS="$(grep -vP '(^#|^\s*$)' "$SDOTDIR/plugins/dotfiles/exa_colors" \
    | paste -sd ':')"
export EXA_COLORS

#######################################
# fasd
#######################################

export _FASD_DATA="$SDOTDIR/plugins/data/.fasd"
export _FASD_SHELL='sh'

. "$SDOTDIR/cache/fasd"

alias v='f -e vim'

#######################################
# thefuck
#######################################

. "$SDOTDIR/cache/thefuck"
