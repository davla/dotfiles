#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
This module defines some custom filters to be used in dotdrop jinja2 templates.
"""

from pathlib import Path

from jinja2.utils import soft_unicode

import python.lib as lib


def format_by(arg: str, format: str) -> str:
    """well"""
    return soft_unicode(format) % arg


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

    found_paths = Path('/home').glob('**/{!s}'.format(path.strip_home()))
    try:
        return str(next(found_paths))
    except StopIteration:
        return None


def home_abs2var(path: str) -> str:
    """Replace the user's home directory absolute path with '$HOME'."""
    return lib.abs_home_first.sub('$HOME', path)


def tildeTo(path: str, replacement: str) -> str:
    """Replace leading tilde with a given string."""
    return lib.tilde_first.sub(replacement, path)


def tilde2home(path: str) -> str:
    """Replace leading tilde with '$HOME'."""
    return tildeTo(path, replacement='$HOME')
