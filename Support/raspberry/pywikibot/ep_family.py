# -*- coding: utf-8  -*-


# File da usare per la configurazione di pywikibot. Assicurati di avere
# l'ultima versione. Da zero:
#
#   git clone https://gerrit.wikimedia.org/r/pywikibot/core.git
#   cd core
#   git submodule update --init
#
# Copia questo file nella cartella "core/pywikibot/families", quindi crea
# il file di configurazione con:
#
#   python pwb.py
#
# Scegli "ep" come famiglia e "it" come lingua, quindi inserisci le tue
# credenziali.  Una volta configurato il tutto , esegui il login con:
#
#   python pwb.py login
#
# Da questo punto in poi il bot dovrebbe essere operativo.  Ricordati di
# richiedere la flag "bot" per avere accesso completo alle API


__version__ = ''

from pywikibot import family

class Family(family.Family):

    def __init__(self):
        family.Family.__init__(self)
        self.name = 'ep'
        self.langs['it'] = 'wiki.pokemoncentral.it'

    def hostname(self, code):
        return 'wiki.pokemoncentral.it'

    def version(self, code):
        return "1.21.2"

    def scriptpath(self, code):
        return ''

    def path(self, code):
        return '/index.php'

    def apipath(self, code):
        return '/api.php'
