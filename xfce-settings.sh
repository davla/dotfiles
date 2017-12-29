#!/usr/bin/env bash

# This script manages XFCE settings by means of the command
# xfconf-settings. It can both export the current settings
# and import previously exported configurations to and from
# a file.
#
# Arguments
#   -$1: The action to be performed. One of 'export' and 'import'
#   -$2: The file name to export to/import from

#####################################################
#
#                   Variables
#
#####################################################

# Separator for array values
SEPARATOR=';'

#####################################################
#
#                   Functions
#
#####################################################

# This function prints the type and the value for
# an xfconf-query command from the values stored in
# a previously exported file.
#
# Arguments:
#   - $1: The values to be converted into
#       xfconf-query format.
function make-values {
    local VALUES="$1"

    # Necessary for the for loop to split by $SEPARATOR
    OLD_IFS="$IFS"
    IFS="$SEPARATOR"

    # Array values are split by $SEPARATOR. For every
    # value, a pair "-t $TYPE -s $VALUE" is printed,
    # as required by the xfconf-query command
    read -a SPLIT_VALUES <<<"$VALUES"

    for VALUE in ${SPLIT_VALUES[@]}; do

        # Determining the type of the value
        { [[ -z "$VALUE" ]] && TYPE='string'; } \
        || \
        { printf '%d' "$VALUE" &> /dev/null && TYPE='int'; } \
        || \
        { printf '%f' "$VALUE" &> /dev/null && TYPE='float'; } \
        || \
        { [[ "$VALUE" == 'true' || "$VALUE" == 'false' ]] && TYPE='bool'; } \
        || \
        { TYPE='string'; }

        echo "-t '$TYPE' -s '$VALUE'"

    done



    # for VALUE in $VALUES; do
    #     echo "$VALUE"
    #     continue
    #
    # done

    IFS="$OLD_IFS"
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

        # Every channel
        for CHANNEL in $(xfconf-query -l | tail -n +2); do
            # Every property in the channel
            for PROP in $(xfconf-query -l -c "$CHANNEL"); do
                VALUE=$(xfconf-query -c "$CHANNEL" -p "$PROP")

                # Value is an array, every item on a separate line.
                # Replacing newline with the separator
                [[ -n $(grep 'array' <<<"$VALUE") ]] && \
                    VALUE=$(tail -n +3 <<<"$VALUE" | tr -s '\n' "$SEPARATOR") #\
                    #|| { VALUE="${VALUE}${SEPARATOR}"; echo >&2 $VALUE; }

                echo "$CHANNEL    $PROP    $VALUE"
            done
        done > "$OUT_FILE"
        ;;

    'import')
        IN_FILE="$2"

        while read LINE; do
            read -a SPLITS <<<"$LINE"

            CHANNEL="${SPLITS[0]}"
            PROP="${SPLITS[1]}"
            VALUES="${SPLITS[@]:2}"

            make-values "$VALUES" | xargs xfconf-query -c "$CHANNEL" -n \
                -p "$PROP"
        done < "$IN_FILE"
        ;;

    *)
        echo 'Action not recognized'
        exit 1
        ;;
esac
