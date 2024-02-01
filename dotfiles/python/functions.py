#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
This module defines some custom functions to be used in dotdrop jinja2
templates.
"""

import glob
import os
import re
import shutil
from pathlib import Path

from python.lib import expand_xdg as xdg

VENV_DIR = ".venv"


def abs_path(path: str) -> str:
    """Return the absolute pathname for a path."""
    return Path(path).expand_home().resolve()


def desktop_with_name(name: str, root_dir_glob="/home/*/.local/share/") -> str:
    """Return .desktop file matching the given name."""
    name_regex = re.compile(f"Name=.*{name}.*")
    desktop_files = glob.iglob(f"{root_dir_glob}/**/*.desktop")
    for desktop_file_name in desktop_files:
        with open(desktop_file_name, "r") as desktop_file:
            if any(map(name_regex.match, desktop_file)):
                return desktop_file_name
    return None


def filename(path: str) -> str:
    """Return the last path component without extension."""
    return Path(path).stem


def second_on_path(executable: str) -> str:
    f"""Return the second PATH match.

    Python virtual environments are ignored if they are in a {VENV_DIR} directory.
    The PATH entries are computed each time to account for changes in PATH.

    :param executable: The executable to find on PATH.
    :return: The second PATH match of `executable`.
    """
    path_entries = (
        entry for entry in os.environ["PATH"].split(os.pathsep) if VENV_DIR not in entry
    )
    next(path_entries)
    return shutil.which(executable, path=os.pathsep.join(path_entries))


def xdg_config(path: str) -> str:
    """Prepend XDG_CONFIG_HOME expansion to path."""
    return xdg("CONFIG_HOME", path)


def xdg_data(path: str) -> str:
    """Prepend XDG_DATA_HOME expansion to path."""
    return xdg("DATA_HOME", path)
