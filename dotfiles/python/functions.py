#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
This module defines some custom functions to be used in dotdrop jinja2
templates.
"""

from pathlib import Path

from jinja2 import pass_context
from jinja2.runtime import Context

from python.lib import expand_xdg as xdg


def abs_path(path: str) -> str:
    """Return the absolute pathname for a path."""
    return Path(path).expand_home().resolve()


def xdg_config(path: str) -> str:
    """Prepend XDG_CONFIG_HOME expansion to path."""
    return xdg("CONFIG_HOME", path)


def xdg_data(path: str) -> str:
    """Prepend XDG_DATA_HOME expansion to path."""
    return xdg("DATA_HOME", path)
