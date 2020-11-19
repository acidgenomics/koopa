#!/usr/bin/env bash
# shellcheck disable=SC2154

# """
# On macOS, use './Configure darwin64-x86_64-cc'
# """

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
