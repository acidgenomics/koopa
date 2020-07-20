#!/usr/bin/env bash
# shellcheck disable=SC2154

file="${name}-${version}.tar.gz"
url="https://download.samba.org/pub/${name}/src/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::cd "${name}-${version}"
flags=(
    "--prefix=${prefix}"
    # '--without-included-zlib'
    '--disable-zstd'
)
if koopa::is_rhel
then
    flags+=('--disable-xxhash')
fi
./configure "${flags[@]}"
make --jobs="$jobs"
make install
