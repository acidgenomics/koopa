#!/usr/bin/env bash
# shellcheck disable=SC2154

_koopa_assert_is_installed python

file="${name}-${version}.tar.gz"
url="https://hisham.hm/${name}/releases/${version}/${file}"
_koopa_download "$url"
_koopa_extract "$file"
cd "${name}-${version}" || exit 1
./configure \
    --disable-unicode \
    --prefix="$prefix"
make --jobs="$jobs"
# > make check
make install
