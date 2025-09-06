#!/usr/bin/env sh

# This script provides the code backing the players provider for
# sway-launcher-desktop. It is meant to be sourced in the providers conf file,
# so that the functions can be used there.

# This function capitalizes stdin and emits it on stdout
capitalize() {
    awk '{ print toupper(substr($0, 1, 1)) substr($0, 2); }'
}

# This function prints the title of the window associated to an active
# MPRIS-enabled media player, if a PID is provided as part of the name.
#
# Arguments:
# - $1: The name of an active MPRIS-enabled media player.
get_title() {
    GET_TITLE_PLAYER="$1"
    case "$GET_TITLE_PLAYER" in
        *'instance'*)
            # Player names with a PID look like this: 'firefox.instance28301'
            GET_TITLE_PID="$(echo "$GET_TITLE_PLAYER" \
                | awk --field-separator '.instance' '{ print $2; }')"

            swaymsg --type get_tree | jq --raw-output \
                ".. | select(.pid? == $GET_TITLE_PID) | .name"

            unset GET_TITLE_PID
            ;;

        *)
            # The player name doesn't contain a PID, nothing to do
            echo "$GET_TITLE_PLAYER"
            ;;

    esac
    unset GET_TITLE_PLAYER
}

# This function emits on stdout the nerd-fonts icon for a given window title.
# It has special cases for a few players (spotify, youtube...), and the rest
# falls back to a generic player icon.
#
# Arguments:
# - $1: The window title
make_icon() {
    # Most cases manually print a space because that pesky VLC has it embedded
    # in the font gylph >_<
    case "$(echo "$1" | tr '[:upper:]' '[:lower:]')" in
        *'spotify'*)
            printf '\Uf1bc '
            ;;

        *'youtube'*)
            printf '\Uf16a '
            ;;

        *'firefox'*)
            printf '\Uf269 '
            ;;

        *'vlc'*)
            printf '\Ufa7b'
            ;;

        *)
            printf '\Uf144 '
            ;;
    esac
}

# This function prints the name to be displayed as an item in the list filtered
# by fzf (3rd column in the list_cmd), given a window title. Apart for a couple
# of special cases (spotify, youtube...), it's the capitalized window title.
#
# Arguments:
# - $1: The window title
make_list_item() {
    MAKE_LIST_ITEM_TITLE="$1"
    case "$(echo "$MAKE_LIST_ITEM_TITLE" | tr '[:upper:]' '[:lower:]')" in
        *'spotify'*)
            echo 'Spotify'
            ;;

        *'youtube'*)
            # Removing anything after 'YouTube'
            echo "$MAKE_LIST_ITEM_TITLE" | sed --regex-extended \
                's/(.*youtube).*/\1/i'
            ;;

        *)
            echo "$MAKE_LIST_ITEM_TITLE"
            ;;

    esac | capitalize
    unset MAKE_LIST_ITEM_TITLE
}

# This function prints an item for every active MPRIS-enabled media player.
# Each item is output on a single line, which contains an icon and the
# title of the player's window, with a few special cases (spotify, youtube...)
make_player_list() {
    active-playerctl --list-all 2> /dev/null \
        | while read -r PLAYER_LIST_PLAYER; do
            PLAYER_LIST_TITLE="$(get_title "$PLAYER_LIST_PLAYER")"
            PLAYER_LIST_ITEM="$(make_list_item "$PLAYER_LIST_TITLE")"
            PLAYER_LIST_ICON="$(make_icon "$PLAYER_LIST_TITLE")"

            printf "%s\034players\034 " "$PLAYER_LIST_PLAYER"
            echo "$PLAYER_LIST_ICON $PLAYER_LIST_ITEM"

            unset PLAYER_LIST_ICON PLAYER_LIST_ITEM PLAYER_LIST_PLAYER \
                PLAYER_LIST_TITLE
        done
}

# This function implements the `list_cmd` sway-launcher-desktop provider entry.
#
# For every active MPRIS-enabled media player, it prints an item on a single
# line, with an icon and a description. If no players can be found, it outputs
# a dedicated message.
list_cmd() {
    LIST_CMD_LIST="$(make_player_list)"
    [ -n "$LIST_CMD_LIST" ] \
        && printf '%s' "$LIST_CMD_LIST" \
        || printf '\034players\034No players found\n'
}

# This function prints the `preview_cmd` sway-launcher-desktop provider entry.
# Given an MPRIS-enabled media player, it prints an icon and the title
# of the player's window, with a few special cases (spotify, youtube...).
#
# Arguments:
# - $1: The name of an active MPRIS-enabled media player.
preview_cmd() {
    get_title "$1" | capitalize
}
