#!/usr/bin/env bash

# FIXME Rework the variable handling in these install scripts.

gnu_mirror="${INSTALL_GNU_MIRROR:?}"
jobs="${INSTALL_JOBS:?}"
name="${INSTALL_NAME:?}"
prefix="${INSTALL_PREFIX:?}"
version="${INSTALL_VERSION:?}"

file="${name}-${version}.tar.xz"
url="${gnu_mirror}/${name}/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::cd "${name}-${version}"
./configure --prefix="$prefix"
make --jobs="$jobs"
# > make check
make install
