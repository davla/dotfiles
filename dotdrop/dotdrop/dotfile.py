"""
author: deadc0de6 (https://github.com/deadc0de6)
Copyright (c) 2017, deadc0de6

represents a dotfile in dotdrop
"""

from dotdrop.linktypes import LinkTypes


class Dotfile:

    def __init__(self, key, dst, src,
                 actions={}, trans_r=None, trans_w=None,
                 link=LinkTypes.NOLINK, cmpignore=[],
                 noempty=False, upignore=[]):
        """constructor
        @key: dotfile key
        @dst: dotfile dst (in user's home usually)
        @src: dotfile src (in dotpath)
        @actions: dictionary of actions to execute for this dotfile
        @trans_r: transformation to change dotfile before it is installed
        @trans_w: transformation to change dotfile before updating it
        @link: link behavior
        @cmpignore: patterns to ignore when comparing
        @noempty: ignore empty template if True
        @upignore: patterns to ignore when updating
        """
        self.key = key
        self.dst = dst
        self.src = src
        self.link = link
        # ensure link of right type
        if type(link) != LinkTypes:
            raise Exception('bad value for link: {}'.format(link))
        self.actions = actions
        self.trans_r = trans_r
        self.trans_w = trans_w
        self.cmpignore = cmpignore
        self.noempty = noempty
        self.upignore = upignore

    def get_vars(self):
        """return this dotfile templating vars"""
        _vars = {}
        _vars['_dotfile_abs_src'] = self.src
        _vars['_dotfile_abs_dst'] = self.dst
        _vars['_dotfile_key'] = self.key
        _vars['_dotfile_link'] = self.link.name.lower()

        return _vars

    def __str__(self):
        msg = 'key:\"{}\", src:\"{}\", dst:\"{}\", link:\"{}\"'
        return msg.format(self.key, self.src, self.dst, self.link.name.lower())

    def __repr__(self):
        return 'dotfile({})'.format(self.__str__())

    def __eq__(self, other):
        return self.__dict__ == other.__dict__

    def __hash__(self):
        return hash(self.dst) ^ hash(self.src) ^ hash(self.key)
