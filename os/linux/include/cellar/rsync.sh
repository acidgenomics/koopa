#!/usr/bin/env bash
# shellcheck disable=SC2154

file="${name}-${version}.tar.gz"
url="https://download.samba.org/pub/${name}/src/${file}"
_koopa_download "$url"
_koopa_extract "$file"
cd "${name}-${version}" || exit 1
# --without-included-zlib
./configure \
    --disable-zstd \
    --prefix="$prefix"
make --jobs="$jobs"
make install
