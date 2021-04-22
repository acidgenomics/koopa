#!/usr/bin/env bash

# Repo transferred from https://github.com/hishamhm/htop to 
# https://github.com/htop-dev/htop in 2020-08.

koopa::assert_is_installed python3
file="${version}.tar.gz"
url="https://github.com/htop-dev/htop/archive/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::cd "${name}-${version}"
./autogen.sh
./configure \
    --disable-unicode \
    --prefix="$prefix"
make --jobs="$jobs"
# > make check
make install
