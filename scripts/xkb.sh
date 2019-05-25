#!/usr/bin/env bash

# This script creates system-wide the custom keyboard layout found in lib.xkb
# and sets it as default.

# A little guide to create a custom layout:
# - Use xev to find out the keycode of what you want to remap.
# - Then, `grep <KEYCODE> /usr/share/X11/xkb/keycodes/evdev` to find out the
#   symbol associated to the keycode (on the left-hand side of the =, between
#   angular brackets).
# - Then, `grep <SYMBOL> /usr/share/X11/xkb/symbols/<LAYOUT_FILE>` to find
#   where the charachters are mapped to that symbol. The scheme is usually:
#   [ no modifiers, shift, AltGr, AltGr + Shift ]. Happy editing!

#####################################################
#
#                   Variables
#
#####################################################

# Path of this script's parent directory
PARENT_DIR="$(dirname "${BASH_SOURCE[0]}")"
XKB_LIB_DIR="$PARENT_DIR/lib/xkb"

XKB_SYS_DIR='/usr/share/X11/xkb/'

#####################################################
#
#                   Privileges
#
#####################################################

# Checking for root privileges: if don't have them, recalling this script with
# sudo
if [[ $EUID -ne 0 ]]; then
    echo 'This script needs to be run as root'
    sudo bash "${BASH_SOURCE[0]}" "$@"
    exit 0
fi

#####################################################
#
#           Creating keyboard layout
#
#####################################################

# Creating the layout system-wide
# grep 'intl-custom' "$XKB_SYS_DIR/symbols/us" > /dev/null 2>&1 \
#     || cat "$XKB_LIB_DIR/symbols-us-intl-custom" >> "$XKB_SYS_DIR/symbols/us"

# Creating alyout metadata, so it's found by the desktop environment
grep 'intl-custom' "$XKB_SYS_DIR/rules/base.lst" > /dev/null 2>&1 || {
    sed -i '/^\s*\sintl\s\s*us/a\
  intl-custom     us: English (US, intl., with dead keys, custom)' \
        "$XKB_SYS_DIR/rules/base.lst"
    cp "$XKB_SYS_DIR/rules/"{base,evdev}.lst
}

grep 'intl-custom' "$XKB_SYS_DIR/rules/base.xml" > /dev/null 2>&1 || {
    XML_LINE="$(grep -n '(US, intl., with dead keys)' \
        "$XKB_SYS_DIR/rules/base.xml" | awk -F ':' '{print $1 + 3}')"
    sed -e "${XML_LINE}i\        <variant>" \
        -e "${XML_LINE}i\          <configItem>" \
        -e "${XML_LINE}i\            <name>intl-custom</name>" \
        -e "${XML_LINE}i\              <description>English (US, \
intl., with dead keys, custom)</description>" \
        -e "${XML_LINE}i\          </configItem>" \
        -e "${XML_LINE}i\        </variant>" \
        -i "$XKB_SYS_DIR/rules/base.xml"
    cp "$XKB_SYS_DIR/rules/"{base,evdev}.xml
}

#####################################################
#
#           Setting default layout
#
#####################################################

cp "$XKB_LIB_DIR/keyboard" /etc/default
