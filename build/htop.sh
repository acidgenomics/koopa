#!/bin/sh

# htop
# https://hisham.hm/htop/releases/
# https://github.com/hishamhm/htop

# Make sure conda isn't active, otherwise can conflict with ncurses.
# libncursesw.so.6

sudo -v
VERSION="2.2.0"
PREFIX="/usr/local"

wget "https://hisham.hm/htop/releases/${VERSION}/htop-${VERSION}.tar.gz"
tar -xzvf "htop-${VERSION}.tar.gz"
cd "htop-${VERSION}"

./configure --prefix="$PREFIX"

make
make check
sudo make install

