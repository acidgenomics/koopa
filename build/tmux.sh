#!/usr/bin/env bash
set -Eeuo pipefail

# Tmux terminal multiplexer
# https://github.com/tmux/tmux

# Error on conda detection.
if [ -x "$(command -v conda)" ]
then
    echo "Error: conda is active." >&2
    exit 1
fi

sudo -v

# Install tmux build dependencies, if necessary.
if [ -x "$(command -v yum)" ]
then
    sudo yum -y install yum-utils
    sudo yum-builddep -y tmux
fi

PREFIX="/usr/local"
VERSION="2.8"

wget "https://github.com/tmux/tmux/releases/download/${VERSION}/tmux-${VERSION}.tar.gz"
tar -xzvf "tmux-${VERSION}.tar.gz"
cd "tmux-${VERSION}"

./configure --prefix="$PREFIX"

make
sudo make install
