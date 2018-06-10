#!/usr/bin/env bash

source "$HOME/.bash_envvars"

# This script uploads a page to Pokémon Central Wiki using pywikibot's
# pagefromfile

# Arguments:
#	-s Summary to be used, defaults to 'Correzione errori'
#	-f file to be used as source, defaults to $PYWIKIBOT_DIR/dicts/dict.txt.
#		If the path is neither absolute nor explicitly relative (eg. it
#		does not begin with '.' or '/') it is resolved relatively to
#       $HOME/pywikibot/dicts
#	-d Flag, activates simulation (eg. nothing will be actually uploaded)
#	-r Flag, removes file after upload

#####################################################
#
#                   Parameters
#
#####################################################

FILE="$PYWIKIBOT_DIR/dicts/dict.txt"
SUMMARY='Correzione errori'
SIMULATE=''
REMOVE='false'

#####################################################
#
#               Input processing
#
#####################################################

while getopts 's:f:dr' OPTION; do
	case $OPTION in
		's')
			SUMMARY="$OPTARG"
			;;
		'f')
            [[ "${OPTARG:0:1}" == '/' || "${OPTARG:0:1}" == '.' ]] \
			    && FILE="$OPTARG" \
                || FILE="$PYWIKIBOT_DIR/dicts/$OPTARG"
			;;
		'd')
			SIMULATE='-simulate'
			;;
		'r')
			REMOVE='true'
			;;
		*)        # getopts already printed an error message
			exit 1
			;;
	esac
done

FILE=$(readlink -f "$FILE")

#####################################################
#
#               File processing
#
#####################################################

# Turning lua code to Scributo module style from pure lua, and then adding
# pagefromfile-friendly tags.

cd "$UTIL_DIR/js/atom-macros" || exit 1

< .nvmrc xargs -i n exec '{}' run-macros.js "$FILE" \
    'toModule' 'moduleToDict'

#####################################################
#
#                   Page upload
#
#####################################################

cd "$PYWIKIBOT_DIR" || exit 1

python pwb.py pagefromfile -pt:1 -notitle -force $SIMULATE \
    -summary:"$SUMMARY" -file:"$FILE"

[[ "$REMOVE" == 'true' ]] && rm "$FILE"
