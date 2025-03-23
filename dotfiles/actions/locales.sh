#!/usr/bin/env sh

# This script generating locales themselves and deals with spellcheckers

# This doesn't work if this script is sourced
. "$(dirname "$0")/../../.dotfiles-env"
. "$(dirname "$0")/../../bot-steps/lib.sh"

#######################################
# Variables
#######################################

# Locales to be generated
LOCALES='C.UTF-8 UTF-8
en_DK.UTF-8 UTF-8
en_US.UTF-8 UTF-8'

#######################################
# Generate locales
#######################################

print_info 'Uncomment locales in /etc/locale.gen'
echo "$LOCALES" | while read -r LOCALE; do
    sed -Ei "s/#\\s*$LOCALE/$LOCALE/" /etc/locale.gen
done

print_info 'Generate locales'
case "$DISTRO" in
    'arch')
        locale-gen
        ;;

    'debian')
        dpkg-reconfigure -f noninteractive locales
        ;;
esac

#######################################
# Deal with spellcheckers
#######################################

print_info 'Alias spellcheckers'
if [ -d /usr/share/hunspell/ ]; then
    for EN_US_FILE_PATH in /usr/share/hunspell/en_US.*; do
        EN_US_EXT="$(basename "$EN_US_FILE_PATH" | cut -d '.' -f 2-)"
        ln --force --symbolic --relative "$EN_US_FILE_PATH" \
            "/usr/share/hunspell/en_DK.$EN_US_EXT"
    done
fi
