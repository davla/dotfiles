#!/usr/bin/env bash

# This script manages XFCE settings by means of the command
# xfconf-settings. It can both export the current settings
# and import previously exported configurations to and from
# a JSON file.
#
# Arguments
#   -$1: The action to be performed. One of 'export' and 'import'
#   -$2: The file name to export to/import from

#####################################################
#
#                   Aliases
#
#####################################################

shopt -s expand_aliases
alias init='head -n -1'
alias last='tail -n 1'
alias flatten='xargs echo -n'

#####################################################
#
#                   Functions
#
#####################################################

function escape-double-quotes {
    sed -z 's/\"/\\"/g' | sed -z 's/\\\\"/\\\\\\"/g'
}

function flatjoin {
    join $@ | escape-double-quotes | flatten
}

function join {
    local SEPARATOR="$1"

    local LINES=$(cat)
    init <<<"$LINES" | awk '{ print $0"'$SEPARATOR'"; }'
    last <<<"$LINES"
}

function json-type {
    local VALUE="$1"

    local JQ_TYPE=$(printf '%q' "$VALUE" | jq -r type 2> /dev/null \
        || echo 'string')
    case "$JQ_TYPE" in
        'number')
            grep '\.' <<<"$VALUE" && echo 'float' || echo 'int'
            ;;
        'boolean')
            echo 'bool'
            ;;
        'string')
            echo 'string'
            ;;
    esac
}

function make-channel {
    while read CHANNEL; do
        echo -n "\"$CHANNEL\": {"
        xfconf-query -l -c "$CHANNEL" | make-property | flatjoin ','
        echo '}'
    done
}

function make-property {
    while read PROPERTY; do
        echo -n "\"$PROPERTY\": "

        VALUE=$(xfconf-query -c "$CHANNEL" -p "$PROPERTY")

        # Value is an array, every item on a separate line.
        if [[ -n $(grep 'array' <<<"$VALUE") ]]; then
            echo -n '['
            tail -n +3 <<<"$VALUE" | value2json | flatjoin ','
            echo ']'
        else
            echo "$VALUE" | value2json
        fi
    done
}

function value2json {
    while read VALUE; do
        local TYPE=$(json-type "$VALUE")

        if [[ "$TYPE" == 'string' ]]; then
            echo -n "$VALUE" | escape-double-quotes | xargs -0 printf '"%s"\n'
        else
            echo "$VALUE"
        fi
    done
}

#####################################################
#
#               Input processing
#
#####################################################

ACTION="$1"

#####################################################
#
#               Action execution
#
#####################################################

case "$ACTION" in
    'export')
        OUT_FILE="$2"
        TMP_FILE=$(mktemp)

        exec 3>&1
        exec > "$TMP_FILE"
        # exec > "$OUT_FILE"

        echo '{'
        xfconf-query -l | tail -n +2 | make-channel | join ','
        echo '}'

        jq '.' "$TMP_FILE" > "$OUT_FILE"
        rm "$TMP_FILE"
        ;;

    'import')
        IN_FILE="$2"

        jq '.' "$IN_FILE"

        # while read LINE; do
        #     read -a SPLITS <<<"$LINE"
        #
        #     CHANNEL="${SPLITS[0]}"
        #     PROP="${SPLITS[1]}"
        #     VALUES="${SPLITS[@]:2}"
        #
        #     make-values "$VALUES" | xargs xfconf-query -c "$CHANNEL" -n \
        #         -p "$PROP"
        # done < "$IN_FILE"
        ;;

    *)
        echo 'Action not recognized'
        exit 1
        ;;
esac
