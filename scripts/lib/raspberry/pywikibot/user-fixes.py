# -*- coding: utf-8 -*-

"""
This file implements custom pywikibot fixes
"""

from __future__ import unicode_literals
from functools import partial

from fixes_data import (aa_aliases, aa_exceptions, tc_aliases, tc_exceptions)


except_inside = [
    r"'{2,3}.+?'{2,3}",
    r'".+?"',
    r'\[\[\w{2}:.+?\]\]',
]


def to_link(exceptions, aliases, match):
    """Return the plain link to a given match.

    This function returns a plain link to the content of the first group in
    the passed match. For example, given the string '{{a|Forza Interiore}}' and
    the regex '\{\{a|(.+?)\}\}', it returns '[[Forza Interiore]]'.
    It can be provided with a list of exceptions for the first match, for which
    no replacement will be performed. For example, given the former string and
    regex, and the exception list ('forza interiore', 'prepotenza'), the
    returned string will be '{{a|Forza Interiore}}'. The elements must be
    lowercase and underscores need to be replaced by spaces.
    It can be provided with a dictionary of aliases for the first match, that
    will be used as links target. The keys are the values of the first match
    and the associated values are the aliases. For example, given the former
    string and regex, and the alias dictionary
    {'fuocodentro': 'Forza Interiore'}, the returned string will be
    '[[Forza Interiore|Fuocodentro]]'. The keys must be lowercase and the
    underscores need to be replaced by spaces.
    If the match is in the form <link_target>|<link_display>, than the link
    target is used for exception and aliasing, while the displayed text is left
    untouched.

    :param exceptions: List of first group values that will not be replaced.
    :type exceptions: List of strings.
    :param aliases: Dictionary of aliases for the first match.
    :type aliases: Dictionary with stirng keys and string values.
    :return string: The plain link to the first group of the match.
    """

    # The link template content. Can contain a | character.
    content = match.group(1)

    # Splitting the link target and what is displayed. If there's nothing to
    # split, then they're equal, so they're both assigned the whole content.
    try:
        link_target, link_display = content.split('|')
    except ValueError:
        link_target, link_display = content, content

    # The key in the exceptions and aliases must be lowercased and with no
    # underscore in place of spaces.
    key = link_target.lower().replace('_', ' ')

    # The link target is an exception, returning the whole match as it is.
    if key in exceptions:
        return match.group(0)

    # Replacing the link target if it has an alias.
    link_target = aliases.get(key, link_target)

    # If link target and displayed text are the same, only one value is
    # interpolated. Two are necessary otherwise.
    return ('[[{0:s}]]'.format(link_target)
            if link_target == link_display
            else '[[{0:s}|{1:s}]]'.format(link_target, link_display))


# This fix fixes grammatically incorrect text and general misspellings.
fixes['grammar'] = {
    'nocase': False,
    'regex': True,
    'exceptions': {
        'inside': except_inside,
    },
    'msg': {
        'it': 'Bot: Fixing grammar'
    },
    'replacements': [
        (ur'chè\b', u'ché'),
        (ur'\bpò\b', "po'"),
        (ur'\bsè\b', u'sé'),
        (ur'\bsé\s+stess', 'se stess'),
        (ur'\bquì\b', 'qui'),
        (ur'\bquà\b', 'qua'),
        (ur'\bfà\b', 'fa'),

        # Fixing unnecessary replacements made above
        (ur'Arché\b', u'Archè'),
    ],
}

# This fix addresses misspellings of brand names, where the case matters.
fixes['names-case-sensitive'] = {
    'nocase': False,
    'regex': True,
    'exceptions': {
        'inside': except_inside,
    },
    'msg': {
        'it': 'Bot: Fixing names - case sensitive'
    },
    'replacements': [
        (ur'Pokè', u'Poké'),
        (ur'POKè', u'POKé'),
    ]
}

# This fix addresses brand names misspellings, where the case doesn't matter.
fixes['names-case-insensitive'] = {
    'nocase': True,
    'regex': True,
    'exceptions': {
        'inside': except_inside,
    },
    'msg': {
        'it': 'Bot: Fixing names - case insensitive'
    },
    'replacements': [
        ('Pallaombra', 'Palla Ombra'),
        ('Iperraggio', 'Iper Raggio'),
        (ur'\bPokéball', u'Poké Ball'),
    ]
}

# This fix removes obsolete templates, turning them into plain links.
fixes['obsolete-templates'] = {
    'nocase': False,
    'regex': True,
    'exceptions': {
        'inside': except_inside,
    },
    'msg': {
        'it': 'Bot: Fixing obsolete templates usage'
    },
    'replacements': [
        (r'\{\{[AaMmPpTt]\|(.+?)\}\}', r'[[\1]]'),
        (r'\{\{[Dd]wa\|(.+?)\}\}', r'[[\1]]'),
        (r'\{\{[Pp]w\|(.+?)\}\}', r'[[\1]]'),
        (r'\{\{[Pp]ietraevo\|(.+?)\}\}', r'[[\1]]'),
        (r'\{\{[Tt]c\|(.+?)\}\}', partial(to_link, tc_exceptions, tc_aliases)),
        (r'\{\{[Aa]a\|(.+?)\}\}', partial(to_link, aa_exceptions, aa_aliases)),
        (r'\{\{MSF', r'\{\{MSP'),
    ]
}
