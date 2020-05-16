#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""This file defines utility functions for python scripts"""

import re

from pathlib import PurePath, Path


tilde_first = re.compile('^~')
home_first = re.compile(r'^\$HOME')


def expand_home(self: PurePath) -> PurePath:
    """Expand leading '~' or '$HOME' for the current user."""
    tilde_expanded = self.expanduser()
    if tilde_expanded.is_absolute():
        # The path in self has a leading '~'
        return tilde_expanded

    new_path = home_first.sub(str(self.home()), str(self))
    return self.__class__(new_path)


def strip_home(self: PurePath) -> PurePath:
    """Strip the current user's home directory.

    This function strips the current user's home directory. The home directory
    can be '~', '$HOME' or its absolute path.
    """
    new_path = re.sub('^' + str(self.home()), '', str(self.expand_home()))
    return self.__class__(new_path)


# Monkey patching pathlib.PurePath
PurePath.expand_home = expand_home
PurePath.strip_home = strip_home
