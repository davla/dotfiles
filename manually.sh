#!/usr/bin/env bash

# This script installs some applications manually, because they're
# not in any repository.

#####################################################
#
#                   Functions
#
#####################################################

# This function returns the initial part of the URL of a GitHub repository
# latest release.
#
# Argunemts:
#   - $1: The GitHub repository name
function latest-release-url {
    local RELEASES_URL="https://api.github.com/repos/$1/releases"
    local DOWNLOAD_URL="https://github.com/$1/releases/download"

    local LATEST_RELEASE
    LATEST_RELEASE=$(wget -O - "$RELEASES_URL/latest" | jq -r '.tag_name')
    echo "$DOWNLOAD_URL/$LATEST_RELEASE"
}

#####################################################
#
#                   Privileges
#
#####################################################

# Checking for root privileges: if don't
# have them, recalling this script with sudo
if [[ $EUID -ne 0 ]]; then
    echo 'This script needs to be run as root'
    sudo bash "$0" "$@"
    exit 0
fi

#####################################################
#
#                   Colorgrab
#
#####################################################

COLORGRAB_HOME='/opt/colorgrab'
DESKTOPS_DIR='/usr/share/applications'
ICONS_DIR='/usr/share/icons/hicolor'

apt-get install libwxgtk3.0-dev
git clone 'https://github.com/nielssp/colorgrab.git' "$COLORGRAB_HOME"
cd "$COLORGRAB_HOME" || exit
cmake .
make
cd - &> /dev/null || exit

find "$COLORGRAB_HOME" -type f -executable -name 'colorgrab' \
    -exec ln -sf '{}' /usr/local/bin/colorgrab \;
cp "$COLORGRAB_HOME/pkg/arch/colorgrab.desktop" "$DESKTOPS_DIR"
chmod +x "$DESKTOPS_DIR/colorgrab.desktop"

cp "$COLORGRAB_HOME/img/scalable.svg" "$ICONS_DIR/scalable/apps/colorgrab.svg"
for IMG in $COLORGRAB_HOME/img/[0-9]*x[0-9]*.png; do
    SIZE_DIR=$(basename "$IMG" .png | xargs -i echo "$ICONS_DIR/{}/apps")

    [[ -d "$SIZE_DIR" ]] && cp "$IMG" "$SIZE_DIR/colorgrab.png"
done
gtk-update-icon-cache "$ICONS_DIR"

#####################################################
#
#               CPU temp throttle
#
#####################################################

TEMP_THROTTLE_ARCH='temp-throttle.zip'
TEMP_THROTTLE_EXEC='/usr/local/sbin/underclock'

wget 'https://github.com/Sepero/temp-throttle/archive/stable.zip' -O \
    "$TEMP_THROTTLE_ARCH"

# Unzipping only the shellscript to stdout
# and redirecting to TEMP_THROTTLE_EXEC
unzip -p "$TEMP_THROTTLE_ARCH" '*.sh' > "$TEMP_THROTTLE_EXEC"

chmod +x "$TEMP_THROTTLE_EXEC"
rm "$TEMP_THROTTLE_ARCH"

#####################################################
#
#               Docker compose
#
#####################################################

COMPOSE_TAG=$(uname -s)-$(uname -m)
COMPOSE_URL="$(latest-release-url 'docker/compose')/docker-compose-$COMPOSE_TAG"
wget -O /usr/local/bin/docker-compose "$COMPOSE_URL"
chmod +x /usr/local/bin/docker-compose

#####################################################
#
#           Docker credential helpers
#
#####################################################

CREDENTIAL_HELPERS_URL="$(latest-release-url \
    'docker/docker-credential-helpers')"
CREDENTIAL_HELPERS_RELEASE="${CREDENTIAL_HELPERS_URL##*/}"
CREDENTIAL_HELPERS_URL="$CREDENTIAL_HELPERS_URL/docker-credential-secretservice-$CREDENTIAL_HELPERS_RELEASE-amd64.tar.gz"

wget -qO - "$CREDENTIAL_HELPERS_URL" | tar x -C /usr/local/bin/
chmod +x docker-credential-secretservice

#####################################################
#
#               Move to next monitor
#
#####################################################

TMP_DIR=$(mktemp -d)

git clone 'https://github.com/vanaoff/move-to-next-monitor.git' "$TMP_DIR"
bash "$TMP_DIR/install.sh"
mv /usr/local/bin/move-to-next-monitor /usr/bin/move-to-monitor

rm -rf "$TMP_DIR"
