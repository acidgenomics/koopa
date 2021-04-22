#!/usr/bin/env bash

koopa::assert_is_linux
name='openssl'
file="${name}-${version}.tar.gz"
url="https://www.${name}.org/source/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::cd "${name}-${version}"
./config \
    --prefix="$prefix" \
    --openssldir="$prefix" \
    shared
make --jobs="$jobs"
# > make test
make install
