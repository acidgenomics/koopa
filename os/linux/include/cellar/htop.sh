#!/usr/bin/env bash
# shellcheck disable=SC2154

# """
# This currently fails with compile with GCC 10:
# multiple definition of `CRT_colors'; CheckItem.o:/t
# https://github.com/hishamhm/htop/issues/986
# """

koopa::assert_is_installed python

file="${name}-${version}.tar.gz"
url="https://hisham.hm/${name}/releases/${version}/${file}"
koopa::download "$url"
koopa::extract "$file"
cd "${name}-${version}" || exit 1
./configure \
    --disable-unicode \
    --prefix="$prefix"
make --jobs="$jobs"
# > make check
make install
