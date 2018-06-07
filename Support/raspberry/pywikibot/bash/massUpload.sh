#!/bin/bash

. $HOME/.bash_envvars

# This script uploads all files in a directory
# to Pokémon Central Wiki with given description,
# using filenames as they are, overwriting if
# told to and using given throttle

# Arguments:
#	- s: Source directory
#	- d: Description
#	- r: Reason for which new versions are uploaded
#	- p: Flag, sets bot throttle to 1
#	- o: Flag, overwrite file if already exists, defaults to no

DIR=''
DESC=''
REASON='Tra poco saranno caricate in batch nuover versioni'
PT=''
OVERWRITE=false

while getopts "s:d:r:po" OPTION; do
	case $OPTION in
		s)
			DIR="$OPTARG"
			;;
		d)
			DESC="$OPTARG"
			;;
		r)
			REASON="$OPTARG"
			;;
		p)
			PT='-putthrottle:1'
			;;
		o)
			OVERWRITE=true
			;;
		*) # getopts already printed an error message
			exit 1
			;;
	esac
done	

if [[ -z $DIR ]]; then
	echo No source directory specified. Aborting
	exit 1
fi
if [[ -z $DESC ]]; then
	echo No description given. Aborting
	exit 1
fi

if [[ $OVERWRITE == true ]]; then

	# Since the bot prompts for confirmation when
	# a file already exists, deleting all of them
	# before uploading

	ls -1 "$DIR" | awk '{print "# [[File:"$0"]]"}' > delete.txt
	python $PYWIKIBOT_DIR/pwb.py delete $PT -always -file:delete.txt -summary:"$REASON"
	rm delete.txt
fi

for FILE in "$DIR"/*; do
	echo y | python $PYWIKIBOT_DIR/pwb.py upload $PT -keep -noverify "$FILE" "$DESC"
done
