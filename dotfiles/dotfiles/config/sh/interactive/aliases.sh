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
alias c='xsel --input --clipboard'
alias p='xsel --output'

{#@@ On wayland copy and paste are only available to unprivileged users @@#}
{%@@ elif on_wayland | is_truthy and user == 'user' -@@%}

# Copy-paste
alias c='wl-copy'
alias p='wl-paste'

{%@@ endif -@@%}

{#@@ Root shell  @@#}
{%@@ if user == 'user' -@@%}

# Root shell
alias root='sudo --shell'

{%@@ endif -@@%}

# Updates
{%@@ if user == 'user' -@@%}

{%@@ if 'arch' in distro_id -@@%}

alias update='yay -Suyy ; sudo flatpak update'

{%@@ elif distro_id == 'debian' -@@%}

alias update='sudo apt update && sudo apt dist-upgrade && sudo apt autoremove'

{%@@ endif -@@%}

{%@@ elif user == 'root' and distro_id == 'debian' -@@%}

alias update='apt update && apt dist-upgrade && apt autoremove'

{%@@ endif -@@%}

{#@@ Power control @@#}
{#@@
    Arch ships with executables that basically use systemd with some wrapping
    https://man.archlinux.org/man/core/systemd-sysvcompat/halt.8.en
@@#}
{%@@ if distro_id == 'debian' -@@%}

# Power control
alias halt='systemctl poweroff'
alias reboot='systemctl reboot'

{%@@ endif -@@%}

alias open='xdg-open'

########################################
# Convenience options aliases
########################################

# Shadow the actual command, as these options won't harm if always included
alias diff='diff --color=auto'
alias grep='grep --color=auto'

# Create new commands, as these options might cause undesired behavior in
# sourced shell code if the command is shadowed
alias ddiff='diff --color=auto --report-identical-files --unified'
alias ggrep='grep --color=auto --perl-regexp'
alias jjq='jq --sort-keys'
alias ssed='sed --regexp-extended'
alias ttar='tar --auto-compress --one-top-level'
alias xxargs='xargs --no-run-if-empty'

########################################
# Typos aliases
########################################

alias gl=' clear'

########################################
# Abbreviation aliases
########################################

alias e='explore'
alias l='list-long'
alias o='open'
alias pg='paginate'
alias t='tree-long'
