#!/usr/bin/env sh

# This script generating locales themselves and deals with spellcheckers

#######################################
# Variables
#######################################

# Locales to be generated
LOCALES='en_DK.UTF-8 UTF-8
en_US.UTF-8 UTF-8'

#######################################
# Generating locales
#######################################

# Uncommenting locales in /etc/locale.gen
echo "$LOCALES" | while read LOCALE; do
    sed -Ei "s/#\\s*(.*)$LOCALE/\\1$LOCALE/g" /etc/locale.gen
done

# Generating locales and timezones
dpkg-reconfigure -f noninteractive locales
dpkg-reconfigure -f noninteractive tzdata

#######################################
# Dealing with spellcheckers
#######################################

# Providing en_DK spellcheckers as aliases to en_US
for EN_US_FILE_PATH in /usr/share/hunspell/en_US.*; do
    EN_US_FILE_NAME="$(basename "$EN_US_FILE_PATH")"
    EN_US_EXT="$(echo "$EN_US_FILE_NAME" | cut -d '.' -f 2-)"

    ln -s "./$EN_US_FILE_NAME" "/usr/share/hunspell/en_DK.$EN_US_EXT"
done
