#!/usr/bin/env bash

# This scripts installs a customized version of the standard
# XFCE menu, including layout, directories and desktop files

#####################################################
#
#                       Layout
#
#####################################################

MENU_DIR="$HOME/.config/menus"

mkdir -p "$MENU_DIR"
cp Support/xfce-applications.menu "$MENU_DIR"
echo 'Layout set'

#####################################################
#
#                   Directories
#
#####################################################

DIRECTORIES_DIR="$HOME/.local/share/desktop-directories"

mkdir -p "$DIRECTORIES_DIR"
cp Support/directories/*.directory "$DIRECTORIES_DIR"
echo 'Directories set'

#####################################################
#
#                   Dektops
#
#####################################################

DESKTOPS_DIR="$HOME/.local/share/applications"

mkdir -p "$DESKTOPS_DIR"
cp Support/desktops/[^_]*.desktop "$DESKTOPS_DIR"
chmod +x "$DESKTOPS_DIR"/*
echo 'Desktops set'

#####################################################
#
#                   Icons
#
#####################################################

ICONS_DIR="$HOME/.local/share/icons"

mkdir -p "$ICONS_DIR"
cp -r Support/icons/[^_]* "$ICONS_DIR"
echo 'Icons set'
