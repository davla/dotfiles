#!/usr/bin/env bash

# This script manages XFCE settings by means of the command
# xfconf-settings. It can both export the current settings
# and import previously exported configurations to and from
# a JSON file.
#
# Arguments:
#   -$1: The action to be performed. One of 'export' and 'import'.
#   -$2: The file name to export to/import from.

#####################################################
#
#                   Aliases
#
#####################################################

shopt -s expand_aliases

# Filters all but the last line of input.
alias init='head -n -1'

# Filters the last line of input.
alias last='tail -n 1'

# Flattens multiple input lines into one.
alias flatten='xargs echo -n'

#####################################################
#
#                   Functions
#
#####################################################

# This filter escapes double quotes, mainly in order
# to prevent them to be removed by xargs. For this
# very same reason, twice-escaped double quotes are
# triple-escaped.
function escape-double-quotes {
    sed -z 's/\"/\\"/g' | sed -z 's/\\\\"/\\\\\\"/g'
}

# This filter listifies lines and then flattens them
# on one single line. escape-double-quotes is called
# bcause flattens uses xargs internally.
#
# Arguments:
#   - $@: whatever listify takes, since they are just
#       passed through.
function flatlistify {
    listify $@ | escape-double-quotes | flatten
}

# This filter appends the given string to every line
# of input but the last, making such string a separator
# for lines.
#
# Arguments:
#   - $1: The string to use as a separator, e.g. to be
#       appended to every input line but the last.
function listify {
    local SEPARATOR="$1"

    local LINES=$(cat)
    init <<<"$LINES" | awk '{ print $0"'$SEPARATOR'"; }'
    last <<<"$LINES"
}

# This function returns the type of the passed value
# as one of the valid xfconf-query command types.
#
# Arguments:
#   - $1: The value whose xfconf-query type will be returned.
function xfconf-type {
    local VALUE="$1"

    # If a string is passed unquoted, jq exits with an error
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

# This filter outputs every xfconf-query channel in the input
# as a JSON object, proprties being the keys and their values
# the values.
function make-channel {
    while read CHANNEL; do
        echo -n "\"$CHANNEL\": {"
        xfconf-query -l -c "$CHANNEL" | make-property | flatlistify ','
        echo '}'
    done
}

# This filter outputs every xfconf-query property in the input
# as a JSON key-value pair, the property name being the key and
# its value being the value. xfconf-query arrays are output as
# JSON arrays.
function make-property {
    while read PROPERTY; do
        echo -n "\"$PROPERTY\": "

        VALUE=$(xfconf-query -c "$CHANNEL" -p "$PROPERTY")

        # Value is an array, every item on a separate line.
        if [[ -n $(grep 'array' <<<"$VALUE") ]]; then
            echo -n '['
            tail -n +3 <<<"$VALUE" | value2json | flatlistify ','
            echo ']'
        else
            echo "$VALUE" | value2json
        fi
    done
}

# This filter outputs the json representation of an
# xfconf-query value.
function value2json {
    while read VALUE; do
        local TYPE=$(xfconf-type "$VALUE")

        # Strings need to be quoted.
        if [[ "$TYPE" == 'string' ]]; then
            echo -n "$VALUE" | escape-double-quotes | xargs -0 printf '"%s"\n'

        # Non-string values need to be left untouched.
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

    # This action exports the urrent xfconf-query configuration
    # as a JSON file. It's first written to a temporary file and
    # then pretty-printed by means of jq.
    'export')
        OUT_FILE="$2"
        TMP_FILE=$(mktemp)

        exec 3>&1
        exec > "$TMP_FILE"
        # exec > "$OUT_FILE"

        echo '{'
        xfconf-query -l | tail -n +2 | make-channel | listify ','
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
