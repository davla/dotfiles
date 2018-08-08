#!/usr/bin/env bash

# This script performs some syntax fixes (both grammar and code) on Pokémon
# Central Wiki

source "$HOME/.bash_envvars"

#####################################################
#
#                   Functions
#
#####################################################

# This function performs the actual replacement with shared parameters and the
# passed replacement pairs
#
# Arguments:
#   - $@: Replacement pairs.
function wiki-replace {
	python pwb.py replace -start:! -always -ns:0 -pt:1 \
        -summary:'Bot: Correzioni automatiche' -regex \
        -exceptinside:"'{2,3}.+?'{2,3}" -exceptinside:'".+?"' \
        -exceptinside:'\[\[\w{2}:.+?\]\]' "$@"
}

#####################################################
#
#                   Replacements
#
#####################################################

cd "$PYWIKIBOT_DIR" || exit 1

# Grammar
wiki-replace 'chè\b' 'ché' '\bpò\b' "po'" '\bsè\b' 'sé' '\bsé\s+stess' \
    'se stess' '\bquì\b' 'qui' '\bquà\b' 'qua' 'Arché\b' 'Archè' 'fà' 'fa'

# Names

# Case-sensitive
wiki-replace 'Pokè' 'Poké' 'POKè' 'POKé'

# Case-insensitive
wiki-replace 'Pallaombra' 'Palla Ombra' 'Iperraggio' 'Iper Raggio' 'Pokéball' \
    'Poké Ball'

# Code
wiki-replace '\{\{[AaMmPpTt]\|(.+?)\}\}' '[[\1]]' '\{\{[Dd]wa\|(.+?)\}\}' \
    '[[\1]]' '\{\{[Pp]w\|(.+?)\}\}' '[[\1]]' '\{\{MSF' '\{\{MSP'
