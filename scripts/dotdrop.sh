#!/usr/bin/env sh

# This script installs dotdrop dependencies in a virtual environment

# This doesn't work if this script is sourced
. "$(dirname "$0")/lib.sh"

#######################################
# Input processing
#######################################

DOTDROP_DIR="$1"

#######################################
# Create dotdrop virtualenv
#######################################

print_info 'Install uv'
case "$DISTRO" in
    'arch')
        sudo pacman -S --needed uv
        ;;

    'debian')
        which uv > /dev/null 2>&1 ||
            # Quick-and-dirty uv installation. github-releases will take over
            # once provisioning is complete
            uname --machine | xargs -I '{}' wget --quiet --output-document - \
                    'https://github.com/astral-sh/uv/releases/latest/download/uv-{}-unknown-linux-gnu.tar.gz' \
                | sudo tar --extract --gzip --strip-components 1 \
                    --directory /usr/local/bin
        ;;
esac

cd "$DOTDROP_DIR" || exit

print_info 'Recreate empty virtual environment'
if { which asdf && asdf which python; } > /dev/null 2>&1; then
    asdf which python | xargs uv venv --python
else
    uv venv
fi

print_info 'Install project dependencies'
uv sync

cd - > /dev/null 2>&1 || exit
