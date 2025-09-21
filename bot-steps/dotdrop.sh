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
            # Quick-and-dirty uv installation. GitHub releases will take over
            # once provisioning is complete
            uname --machine | xargs -I '{}' wget --quiet --output-document - \
                    'https://github.com/astral-sh/uv/releases/latest/download/uv-{}-unknown-linux-gnu.tar.gz' \
                | sudo tar --extract --gzip --strip-components 1 \
                    --directory /usr/local/bin
        ;;
esac

cd "$DOTDROP_DIR" || exit

print_info 'Recreate empty virtual environment'
if which devbox > /dev/null 2>&1; then
    devbox install
    devbox run which python | xargs uv venv --clear --python
else
    uv venv --clear
fi

print_info 'Install project dependencies'
# Compiling bytecode now to ensure that created files have non-root
# permissions. By default uv compiles bytecode lazily the first time a command
# is executed in the virtual environment, and if that happens as root, then the
# files are created with root permissions.
uv sync --compile-bytecode

cd - > /dev/null 2>&1 || exit
