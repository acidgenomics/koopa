#!/bin/sh

# htop
# https://hisham.hm/htop/releases/
# https://github.com/hishamhm/htop

# Error on conda detection.
# Can conflict with ncurses: libncursesw.so.6
if [ -x "$(command -v conda)" ]
then
    echo "Error: conda is active." >&2
    exit 1
fi

sudo -v

VERSION="2.2.0"
PREFIX="/usr/local"

wget "https://hisham.hm/htop/releases/${VERSION}/htop-${VERSION}.tar.gz"
tar -xzvf "htop-${VERSION}.tar.gz"
cd "htop-${VERSION}" || return 1

./configure --prefix="$PREFIX"

make
make check
sudo make install

