#!/usr/bin/env bash

koopa::assert_is_installed makeinfo  # texinfo
file="${name}-${version}.tar.xz"
url="${gnu_mirror}/${name}/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::cd "${name}-${version}"
./configure --prefix="$prefix"
make --jobs="$jobs"
# > make check
make install
