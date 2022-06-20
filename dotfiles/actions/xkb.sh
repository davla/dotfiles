#!/usr/bin/env sh

# This script keeps xkb base.* and evdev.* rules synchornized, by copying the
# former into the latter

# This doesn't work if this script is sourced
. "$(dirname "$0")/../../scripts/lib.sh"

#######################################
# Variables
#######################################

# Xkb rules directory path
XKB_RULES_DIR='/usr/share/X11/xkb/rules'

#######################################
# Synchronize xkb rules
#######################################

print_info 'Synchronize xkb rules'
cp "$XKB_RULES_DIR/base.xml" "$XKB_RULES_DIR/evdev.xml"
cp "$XKB_RULES_DIR/base.lst" "$XKB_RULES_DIR/evdev.lst"
