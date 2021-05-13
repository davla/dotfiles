#!/usr/bin/env sh

# {{@@ header() @@}}

# This script defines some POSIX shell aliases that are useful in interactive
# shells only

#######################################
# Core commands aliases
#######################################

{%@@ if on_x11 | is_truthy -@@%}

alias c='xsel -i -b'
alias p='xsel -o'

{#@@ On wayland copy and paste are only available to unprivileged users @@#}
{%@@ elif on_wayland | is_truthy and user == 'user' -@@%}

alias c='wl-copy'
alias p='wl-paste'

{%@@ endif @@%}
{%@@ if user == 'user' -@@%}

alias root='sudo -s'

{#@@ yay can only be invoked by unprivileged users @@#}
{%@@ if env['DISTRO'] == 'arch' -@@%}

alias update='yay -Suyy'

{%@@ endif @@%}
{%@@ elif user == 'root' @@%}
{%@@ if env['DISTRO'] == 'debian' @@%}

alias update='apt-get update && apt-get upgrade'

{%@@ endif @@%}
{%@@ endif -@@%}

#######################################
# New commands
#######################################

alias chuck="curl -s http://api.icndb.com/jokes/random/ | jq -r '.value.joke'"

########################################
# Typos aliases
########################################

alias gl=' clear'
