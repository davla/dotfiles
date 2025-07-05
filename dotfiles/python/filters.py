#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
This module defines some custom filters to be used in dotdrop jinja2 templates.
"""

from pathlib import Path
from typing import Union

import python.lib as lib
from markupsafe import soft_str


def format_by(arg: str, format: str) -> str:
    """Format filter alternative to be used with jinja map filter.

    The rationale behind this filter is that the built-in format filter can't
    take in the placeholder values via the map filter, as it takes the format
    as the first argument. Therefore, this filter achieves a similar goal, but
    with the arguments swapped.

    :param arg: The values for the placeholders in the format string.
    :return: The formatted string.
    """
    return soft_str(format) % arg


def find_in_home(path: str) -> str:
    """Find a path starting '~' or '$HOME' in /home.

    This filter finds a path in /home. The path can start with '~' and '$HOME'.
    If their expansion for the current user produces an existing path, then
    the path is returned unchanged, ie. with '~' or '$HOME' unexpanded.
    Otherwise they are stripped and the whole /home subtree is crawled. The
    first matching path is returned.

    :param path: The input path.
    :return: path unchanged if it is found in the current user home directory,
        otherwise the first match in the whole /home subtree.
    """
    path = Path(path)

    if path.expand_home().exists():
        return str(path)

    found_paths = Path("/home").glob("**/{!s}".format(path.strip_home()))
    try:
        return str(next(found_paths))
    except StopIteration:
        return None


def is_truthy(value: Union[bool, str]) -> bool:
    """Return true if value is True or 'true' (case insensitive).

    This filter normalizes bool values and strings to bools. The former are
    returned untouched, while the latter is mapped to True only if it's
    case-insensitively equal to 'true'.

    The rationale behind this filter is that in templated expressions in
    dotdrop config files are always types as YAML strings, because Jinja
    renders templates as strings. This filter is thus meant to overcome this
    limitation for boolean expressions, by allowing "boolean" strings and YAML
    booleans to be used interchangeably.

    :param value: The input value.
    :return: whether value is to be considered as a bool True.
    """
    if type(value) == str:
        value = value.lower() == "true"
    return value


def homeAsTilde(path: str | Path) -> str:
    """Ensure home directory as tilde."""
    try:
        return "~/" + str(Path(path).relative_to(Path.home()))
    except ValueError:
        return path


def home_abs2var(path: str) -> str:
    """Replace the user's home directory absolute path with '$HOME'."""
    return lib.abs_home_first.sub("$HOME", path)


def tildeTo(path: str, replacement: str) -> str:
    """Replace leading tilde with a given string."""
    return lib.tilde_first.sub(replacement, path)


def tilde2home(path: str) -> str:
    """Replace leading tilde with '$HOME'."""
    return tildeTo(path, replacement="$HOME")
