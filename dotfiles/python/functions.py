#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
This module defines some custom functions to be used in dotdrop jinja2
templates.
"""

import glob
import os
import re
from itertools import islice
from pathlib import Path

from jinja2 import Environment, pass_environment
from python.lib import expand_xdg as xdg

VENV_DIR = ".venv"


def abs_path(path: str) -> str:
    """Return the absolute pathname for a path."""
    return Path(path).expand_home().resolve()


def desktop_with_name(name: str, root_dir_glob="/home/*/.local/share/") -> str:
    """Return .desktop file matching the given name case-insensitively."""
    name_regex = re.compile(f"Name=.*{name}.*", re.IGNORECASE)
    desktop_files = glob.iglob(f"{root_dir_glob}/**/*.desktop")
    for desktop_file_name in desktop_files:
        with open(desktop_file_name, "r") as desktop_file:
            if any(map(name_regex.match, desktop_file)):
                return desktop_file_name
    return None


def filename(path: str) -> str:
    """Return the last path component without extension."""
    return Path(path).stem


@pass_environment
def join_file_lines(
    env: Environment, path: str, separator: str = "", skip_marker: str = "#"
) -> str:
    """Return the lines in a file joined by a separator.

    If the file is a jinja template, it will be rendered.

    Blank lines are skipped. So are lines starting with the given skip marker,
    optionally preceded by whitespace.

    :param path: The path of the input file.
    :param separator: The separator used to join the file's lines.
    :return: The lines in the files joined by the separator.
    """
    file_content = env.get_template(path).render()
    lines = (line.strip() for line in file_content.splitlines())
    return separator.join(
        line for line in lines if line and not line.startswith(skip_marker)
    )


def second_on_path(executable: str) -> str:
    f"""Return the second PATH match of executable, or the first if there is one match

    Python virtual environments are ignored if they are in a {VENV_DIR} directory.
    The PATH entries are computed each time to account for changes in PATH.

    :param executable: The executable to find on PATH.
    :return: The second PATH match of `executable`, or the first if there is one match.
    """
    path_matches = (
        path_exec
        for path_dir in os.environ["PATH"].split(os.pathsep)
        if VENV_DIR not in path_dir
        and os.access(path_exec := os.path.join(path_dir, executable), os.X_OK)
    )
    try:
        # The last match is the second, unless the there is only one match. In fact,
        # islice returns the whole generator if it's too short
        return list(islice(path_matches, 2))[-1]
    except IndexError:
        raise ValueError(executable + " was not found on PATH.")


def xdg_config(path: str) -> str:
    """Prepend XDG_CONFIG_HOME expansion to path."""
    return str(xdg("CONFIG_HOME", path))


def xdg_data(path: str) -> str:
    """Prepend XDG_DATA_HOME expansion to path."""
    return str(xdg("DATA_HOME", path))
