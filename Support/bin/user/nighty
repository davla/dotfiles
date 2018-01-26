#!/usr/bin/env bash

# This script uploads a page to Pokémon Central Wiki
# by using pywikibot's pagefromfile. Modules are also
# converted from standalone Lua to Scribunto format

# Arguments:
#	-s Summary to be used, defaults to 'Correzione errori'
#	-f file to be used as source, defaults to $PYWIKIBOT_DIR/dicts/dict.txt.
#		If the path is neither absolute nor explicitly relative (eg. it
#		does not begin with '.' or '/') it is resolved relatively to
#		$HOME/pywikibot/dicts
#	-d Flag, activates simulation (eg. nothing will be actually uploaded)
#	-r Flag, removes file after upload

#####################################################
#
#                   Parameters
#
#####################################################

. "$HOME/.bashrc"

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
			case ". /" in
				*${OPTARG:0:1}*)
					FILE="$OPTARG"
					;;
				*)
					FILE="$PYWIKIBOT_DIR/dicts/$OPTARG"
					;;
			esac
			;;

		'd')
			SIMULATE='-simulate'
			;;

		'r')
			REMOVE='true'
			;;

		*)  # getopts has already printed an error message
			exit 1
			;;
	esac
done

#####################################################
#
#       Standalone Lua to Scribunto conversion
#
#####################################################

# lua geanyMacro.lua "$FILE" tomodule

#####################################################
#
#                   Page upload
#
#####################################################

python "$PYWIKIBOT_DIR/pwb.py" pagefromfile -pt:1 -notitle -force $SIMULATE \
    -summary:"$SUMMARY" -file:"$FILE"
[[ "$REMOVE" == 'true' ]] && rm "$FILE"
