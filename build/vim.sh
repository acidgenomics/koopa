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
    sudo yum -y install yum-utils
    sudo yum-builddep -y vim
fi

PREFIX="/usr/local"
VERSION="8.1.0847"

wget "https://github.com/vim/vim/archive/v${VERSION}.tar.gz"
tar -xzvf "v${VERSION}.tar.gz"
cd "vim-${VERSION}"

./configure --prefix="$PREFIX"
make
make test
sudo make install
