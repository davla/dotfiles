#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
This module defines some custom functions to be used in dotdrop jinja2
templates.
"""

from python.lib import expand_xdg as xdg


def xdg_config(path: str) -> str:
    """Prepend XDG_CONFIG_HOME expansion to path."""
    return xdg('CONFIG_HOME', path)


def xdg_data(path: str) -> str:
    """Prepend XDG_DATA_HOME expansion to path."""
    return xdg('DATA_HOME', path)
