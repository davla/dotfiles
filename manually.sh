#!/usr/bin/env bash

# This script installs some applications manually, because they're
# not in any repository.

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
git clone 'git@github.com:nielssp/colorgrab.git' "$COLORGRAB_HOME"
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

LATEST_COMPOSE=$(wget -O - \
        'https://api.github.com/repos/docker/compose/releases/latest' \
    | jq -r '.tag_name')
COMPOSE_TAG=$(uname -s)-$(uname -m)
wget -O /usr/local/bin/docker-compose \
    "https://github.com/docker/compose/releases/download/$LATEST_COMPOSE/docker-compose-$COMPOSE_TAG"
chmod +x /usr/local/bin/docker-compose

#####################################################
#
#               Move to next monitor
#
#####################################################

TMP_DIR=$(mktemp -d)

git clone 'git@github.com:jc00ke/move-to-next-monitor.git' "$TMP_DIR"
bash "$TMP_DIR/install.sh"
mv /usr/local/bin/move-to-next-monitor /usr/bin/move-to-monitor

rm -rf "$TMP_DIR"
