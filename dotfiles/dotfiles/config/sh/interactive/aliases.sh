#!/usr/bin/env sh

# {{@@ header() @@}}

# This script defines some POSIX shell aliases that are useful in interactive
# shells only

#######################################
# Core commands aliases
#######################################

{#@@ Copy-paste @@#}
{%@@ if on_x11 | is_truthy -@@%}

# Copy-paste
alias c='xsel -i -b'
alias p='xsel -o'

{#@@ On wayland copy and paste are only available to unprivileged users @@#}
{%@@ elif on_wayland | is_truthy and user == 'user' -@@%}

# Copy-paste
alias c='wl-copy'
alias p='wl-paste'

{%@@ endif -@@%}

{#@@ Root shell  @@#}
{%@@ if user == 'user' -@@%}

# Root shell
alias root='sudo -s'

{%@@ endif -@@%}

{#@@ Updates @@#}
{%@@ if env['DISTRO'] == 'arch' and user == 'user' -@@%}

# Updates
alias update='yay -Suyy'

{%@@ elif env['DISTRO'] == 'debian' and user == 'root' -@@%}

# Updates
alias update='apt-get update && apt-get upgrade'

{%@@ endif -@@%}

{#@@ Power control @@#}
{#@@
    Arch ships with executables that basically use systemd with some wrapping
    https://man.archlinux.org/man/core/systemd-sysvcompat/halt.8.en
@@#}
{%@@ if env['DISTRO'] == 'debian' -@@%}

# Power control
alias halt='systemctl poweroff'
alias reboot='systemctl reboot'

{%@@ endif -@@%}

########################################
# Shortening aliases
########################################

alias paginate='less --no-init --quit-if-one-screen'

#######################################
# New commands
#######################################

alias chuck="curl -s http://api.icndb.com/jokes/random/ | jq -r '.value.joke'"

########################################
# Typos aliases
########################################

alias gl=' clear'
