#!/usr/bin/env sh

# This script provides the code backing the clipman provider for
# sway-launcher-desktop. It is meant to be sourced in the providers conf file,
# so that the functions can be used there.

# The whole logic revolves around using indices and null-terminators for items
# in the clipman clipboard history. This is due to the fact that history
# entries are not suitable to be items in sway-launcher-desktop's `list_cmd`,
# since they can contain newlines and  `list_cmd` is line-based. In practice,
# what happens is that `list_cmd` items are the indices of history entries, and
# `preview_cmd` and `launch_cmd` use those indices to retrieve the actual
# history entry.

# This function outputs to stdout a null-separated list containing the
# clipboard history entries stored in clipman.
get_history() {
    clipman pick --tool=STDOUT --print0
}

# This function outputs a clipboard history entry stored in clipman given its
# 1-based index.
#
# Arguments:
# - $1: the 1-based index of the history entry
get_nth_history_entry() {
    # xargs turns the null-terminator to a newline
    get_history | sed --null-data "${1}q;d" | xargs --null --max-args 1
}

# This function implements the `list_cmd` sway-launcher-desktop provider entry.
#
# For every entry in the clipman history, it prints its 1-based index and the
# first line, followed by an ellipsis if there is more than one line.
list_cmd() {
    get_history | awk '
        BEGIN {
            # Using null-bytes as record separator, to be able to read from
            # clipman --print0
            RS = "\0";

            # This makes it easy to print the first line of the record, and to
            # check if there are more than one line
            FS = "\n";

            # This is the sway-launcher-desktop `list_cmd` field separator.
            # This way we can print a `list_cmd` line by passing each field as
            # a separate print argument
            OFS = "\034";
        }

        {
            # Fields are lines, hence NF is the number of lines
            LINE = NF > 1 ? $1"..." : $1;
            print NR,"clipman",LINE;
        }'
}
