#!/usr/bin/env sh

# This script installs packages not related to anything else on a Debian
# system, and performs some additional setup for some of them when required.
#
# Arguments:
#   - $1: user for which rootless podman is set up. Optional, defaults to $USER

# This doesn't work if this script is sourced
. "$(dirname "$0")/../../.dotfiles-env"
. "$(dirname "$0")/../lib.sh"

#######################################
# Functions
#######################################

# This function removes unwanted packages
clean() {
    # Unset -e so that non-existing packages won't make the script exit
    echo "$-" | grep 'e' > /dev/null 2>&1 \
        && HAS_E='true' \
        || HAS_E='false'
    set +e

    apt-get purge -y abiword-common
    apt-get purge -y anacron
    apt-get purge -y audacious
    apt-get purge -y ayatana-indicator-common
    apt-get purge -y calendar-google-provider
    apt-get purge -y conky-std
    apt-get purge -y cron
    apt-get purge -y xfce4-clipman
    apt-get purge -y xfce4-clipman-plugin
    apt-get purge -y deja-vu
    apt-get purge -y disk-manager
    apt-get purge -y epiphany-browser-data
    apt-get purge -y exaile
    apt-get purge -y exfalso
    apt-get purge -y evince
    apt-get purge -y fairymax
    apt-get purge -y firefox-esr
    apt-get purge -y gftp-common
    apt-get purge -y gnome-chess
    apt-get purge -y gnome-mplayer
    apt-get purge -y gnome-schedule
    apt-get purge -y gnome-user-guide
    apt-get purge -y gnote
    apt-get purge -y gnuchess
    apt-get purge -y gnuchess-book
    apt-get purge -y gpicview
    apt-get purge -y hexchat-common
    apt-get purge -y hexchat-perl
    apt-get purge -y hexchat-plugins
    apt-get purge -y hexchat-python
    apt-get purge -y hoichess
    apt-get purge -y hv3
    apt-get purge -y iagno
    apt-get purge -y icedove
    apt-get purge -y iceowl-extension
    apt-get purge -y iceweasel
    apt-get purge -y leafpad
    apt-get purge -y libabiword-2.9
    apt-get purge -y libflorence-1.0-1
    apt-get purge -y liferea-data
    apt-get purge -y mc-data
    apt-get purge -y metacity
    apt-get purge -y minissdpd
    apt-get purge -y mutt
    apt-get purge -y nautilus
    apt-get purge -y oracle-java6-installer
    apt-get purge -y oracle-java6-set-default
    apt-get purge -y xfce4-notes
    apt-get purge -y pidgin-data
    apt-get purge -y plymouth
    apt-get purge -y python3-packagekit
    apt-get purge -y python-libturpial
    apt-get purge -y radiotray
    apt-get purge -y ristretto
    apt-get purge -y sambashare
    apt-get purge -y shotwell-common
    apt-get purge -y smtube
    apt-get purge -y tali
    apt-get purge -y tk-html3
    apt-get purge -y terminator
    apt-get purge -y uget
    apt-get purge -y wbar
    apt-get purge -y wine
    apt-get purge -y xboard
    apt-get purge -y xchat-common
    apt-get purge -y xfburn

    [ "$HAS_E" = 'true' ] && set -e
    unset HAS_E
}

#######################################
# Input processing
#######################################

USER_NAME="${1:-$USER}"

#######################################
# Repositories dotfiles
#######################################

print_info 'Install package manager dotfiles'
dotdrop install -p packages
print_info 'Update package index'
apt-get update

#######################################
# Installing Drivers
#######################################

# shellcheck disable=2039
case "$HOST" in
    'personal')
        print_info "Install drivers for host $HOST"
        apt-get install firmware-realtek firmware-iwlwifi
        ;;
esac

#######################################
# Installing GUI applications
#######################################

if [ "$DISPLAY_SERVER" != 'headless' ]; then
    # Installation
    # shellcheck disable=2039
    case "$HOST" in
        'personal')
            print_info "Install GUI packages for $HOST"
            apt-get install asunder blueman brasero calibre caprine dropbox \
                gimp gufw handbrake-gtk libreoffice-calc libreoffice-impress \
                libreoffice-writer kid3 remmina simple-scan soundconverter \
                system-config-printer thunderbird transmission-gtk vlc
                ;;
    esac

    print_info 'Install GUI packages shared across all hosts'
    apt-get install alacritty atril baobab code-insiders firefox-beta gdebi \
        geany gnome-clocks gnome-disk-utility gparted hardinfo pavucontrol \
        peek seahorse spotify-client synaptic xfce4-screenshooter

    # Dotfiles
    print_info 'Install GUI packages dotfiles'
    sudo --user "$USER_NAME" dotdrop install -p gui
fi

#######################################
# Installing CLI applications
#######################################

# Installation
# shellcheck disable=2039
case "$HOST" in
    'personal')
        print_info "Install CLI packages for $HOST"
        apt-get install autorandr cabal-install cups ghc gifsicle git-review \
            handbrake-cli hlint imagemagick intel-microcode lame lua luacheck \
            luarocks libghc-hspec-dev mercurial nordvpn podman-compose \
            python-requests-futures python3-gdbm python3-gpg python3-lxml \
            python3-pygments python3-requests python3-requests-oauthlib \
            thunar-dropbox-plugin
            ;;

    'work')
        print_info "Install CLI packages for $HOST"
        apt-get install amd64-microcode awscli docker-compose-plugin \
            dotnet-sdk-7.0 dotnet-sdk-8.0 dotnet-sdk-9.0 i3lock xss-lock
        ;;
esac

print_info 'Install CLI packages shared across all hosts'
apt-get install apt-transport-https autoconf automake build-essential cmake \
    cmatrix cowsay curl dbus-x11 dkms dos2unix fonts-freefont-otf fonts-nanum \
    fortune g++ gdb git git-secret gvfs-backends htop hunspell hunspell-en-us \
    hunspell-it jq libbz2-dev liblzma-dev libncurses-dev libnotify-bin \
    libreadline-dev libsecret-1-dev libsqlite3-dev libssl-dev lua5.4 make \
    mate-polkit mmv mgitstatus moreutils nfs-common nyancat p7zip \
    pipewire-jack playerctl podman-docker pycodestyle python3 python3-pip rar \
    shellcheck sl systemd-cron thunar-archive-plugin tk-dev uni2ascii unrar \
    vim wmctrl xdotool xserver-xorg-input-synaptics yad zip

# Dotfiles
print_info 'Install CLI packages dotfiles'
sudo --user "$USER_NAME" dotdrop install -p cli -U user
if dotdrop -bG files -p cli -U root 2> /dev/null \
    | grep --extended-regexp --invert-match --quiet '(^[[:blank:]]*|":)$'; then
    dotdrop install -p cli -U root
fi

#######################################
# Clean & upgrade
#######################################

print_info 'Clean preinstalled software'
clean

print_info 'Upgrade system'
apt-get upgrade

#######################################
# Packages setup
#######################################

# Rootless podman
print_info "Allow $USER_NAME to run rootless podman"
id "$USER_NAME" \
    | sed --regexp-extended 's/uid=([0-9]+).+ gid=([0-9]+).+/\1 \2/' \
    | {
        # Use shell group here because the variables created by read are only
        # available in the subshell created by the pipe
        read -r USER_ID GROUP_ID

        SUB_UID_START="$(( USER_ID + 99000 ))"
        usermod --add-subuids "$SUB_UID_START-$(( SUB_UID_START + 65535 ))" \
            "$USER_NAME"

        SUB_GID_START="$(( GROUP_ID + 99000 ))"
        usermod --add-subgids "$SUB_GID_START-$(( SUB_GID_START + 65535 ))" \
            "$USER_NAME"
    }
podman system migrate

if [ "$HOST" = 'work' ]; then
    print_info "Make docker-compose use $USER_NAME's rootless podman"
    systemctl --machine "$USER_NAME@" --user enable --now podman.socket
    sudo --user "$USER_NAME" sh -c '
        podman info --format "{{.Host.RemoteSocket.Path}}" \
            | xargs -I "{}" \
                podman context create podman --docker "host=unix://{}";
        podman context use podman
    '
fi

# NordVPN
if [ "$HOST" = 'personal' ]; then
    print_info 'Configure NordVPN'
    groupadd -r nordvpn
    usermod -aG nordvpn "$USER_NAME"
    sudo --user "$USER_NAME" nordvpn-config
fi
