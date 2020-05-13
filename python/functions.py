#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
This module defines some custom functions to be used in dotdrop jinja2
templates.
"""

from jinja2 import contextfunction
from jinja2.runtime import Context

from python.lib import expand_xdg as xdg


@contextfunction
def vars_with_prefix(context: Context, prefix: str) -> dict:
    """Return the variables starting with a prefix as a dict.

    This function groups the available variables whose names start with a given
    prefix into a dictionary. The keys are the variable names, with the prefix
    stripped away. The values are the variables' values. The prefix is appended
    an underscore, if it doesn't end with one, both when filtering the
    variables and when stripping the dictionary keys.

    :param context: Jinja context.
    :param prefix: The prefix to filter variables. An underscore is appended if
                   it is not the last character.
    :return: A dictionary containing the variables whose names start with
             prefix.
    """
    prefix = prefix if prefix.endswith('_') else prefix + '_'

    # Injected variables are defined in context.parent, while variables created
    # in the template are in context.vars. Thus, the two dictionaries are
    # merged to have all the variables together. context.var is afterwards so
    # that local variables override the injected ones.
    vars = {**context.parent, **context.vars}

    return {
        name[len(prefix):]: value
        for name, value in vars.items()
        if name.startswith(prefix)
    }


def xdg_config(path: str) -> str:
    """Prepend XDG_CONFIG_HOME expansion to path."""
    return xdg('CONFIG_HOME', path)


def xdg_data(path: str) -> str:
    """Prepend XDG_DATA_HOME expansion to path."""
    return xdg('DATA_HOME', path)
