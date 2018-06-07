#!/bin/bash

. $HOME/.bash_envvars

# This script uploads a page to Pokémon
# Central Wiki using pywikibot's pagefromfile

# Arguments:
#	-s Summary to be used, defaults to 'Correzione errori'
#	-f file to be used as source, defaults to $PYWIKIBOT_DIR/dicts/dict.txt.
#		If the path is neither absolute nor explicitly relative (eg. it
#		does not begin with '.' or '/') it is resolved relatively to
		# $HOME/pywikibot/dicts
#	-d Flag, activates simulation (eg. nothing will be actually uploaded)
#	-r Flag, removes file after upload

FILE=$PYWIKIBOT_DIR/dicts/dict.txt
SUMMARY='Correzione errori'
SIMULATE=""
REMOVE=false

while getopts "s:f:dr" OPTION; do
	case $OPTION in
		s) 
			SUMMARY="$OPTARG"
			;;
		f) 
			case ". /" in
				*${OPTARG:0:1}*)
					FILE="$OPTARG"
					;;
				*)
					FILE="$PYWIKIBOT_DIR/dicts/$OPTARG"
					;;
			esac
			;;
		d)
			SIMULATE='-simulate'
			;;
		r)
			REMOVE=true
			;;
		*)
			exit 1
			;;
	esac
done

cd $PYWIKIBOT_DIR

# Turning lua code to Scributo module style from pure lua

lua geanyMacro.lua "$FILE" tomodule

python pwb.py pagefromfile -pt:1 -notitle -force $SIMULATE -summary:"$SUMMARY" -file:"$FILE"

$REMOVE && rm "$FILE"
