#!/usr/bin/env bash
set -Eeuo pipefail

# Vim
# https://github.com/vim/vim

# Error on conda detection.
if [ -x "$(command -v conda)" ]
then
    echo "Error: conda is active." >&2
    exit 1
fi

sudo -v

# Install vim build dependencies, if necessary.
if [ -x "$(command -v yum)" ]
then
    sudo yum install yum-utils
    sudo yum-builddep -y emacs
fi

PREFIX="/usr/local"
VERSION="26.1"

wget "http://ftp.gnu.org/gnu/emacs/emacs-${VERSION}.tar.xz"
tar -xJvf "emacs-${VERSION}.tar.xz"
cd "emacs-${VERSION}"

./configure --prefix="$PREFIX"

make

# This step doesn't work on tarball.
# make check

sudo make install
