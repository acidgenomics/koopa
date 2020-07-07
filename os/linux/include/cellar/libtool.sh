#!/usr/bin/env bash
# shellcheck disable=SC2154

file="${name}-${version}.tar.xz"
url="${gnu_mirror}/${name}/${file}"
koopa::download "$url"
koopa::extract "$file"
cd "${name}-${version}" || exit 1
./configure --prefix="$prefix"
make --jobs="$jobs"
# > make check
make install
