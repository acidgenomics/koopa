#!/usr/bin/env bash
set -Eeuxo pipefail

# Emacs text editor
# See also:
# - https://www.gnu.org/software/emacs/index.html#Releases
# - https://github.com/emacs-mirror/emacs

# Error on conda detection.
if [ -x "$(command -v conda)" ]
then
    echo "Error: conda is active." >&2
    exit 1
fi

sudo -v

# Install build dependencies, if necessary.
if [ -x "$(command -v yum)" ]
then
    sudo yum -y install yum-utils
    sudo yum-builddep -y emacs
fi

PREFIX="/usr/local"
VERSION="26.1"

wget "http://ftp.gnu.org/gnu/emacs/emacs-${VERSION}.tar.xz"
tar -xJvf "emacs-${VERSION}.tar.xz"
cd "emacs-${VERSION}" || return 1

./configure --prefix="$PREFIX"

make
# This step doesn't work on tarball.
# make check
sudo make install

emacs --version
