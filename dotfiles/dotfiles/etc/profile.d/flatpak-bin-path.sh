#!/usr/bin/env sh
#
# {{@@ header() @@}}

# This script adds flatpak binary exports directories to PATH

{%@@ set flatpak_bin_exports = ['/var/lib', '${XDG_DATA_HOME:-~/.local/share}']
    | map('format_by', '%s/flatpak/exports/bin') | join(':') -@@%}

export PATH="${PATH%%:{{@@ flatpak_bin_exports @@}}}:{{@@ flatpak_bin_exports @@}}"
