#!/usr/bin/env bash
# shellcheck disable=SC2154

# """
# On macOS, use './Configure darwin64-x86_64-cc'
# """

file="openssl-${version}.tar.gz"
url="https://www.openssl.org/source/${file}"
_koopa_download "$url"
_koopa_extract "$file"
cd "openssl-${version}" || exit 1
./config \
    --prefix="$prefix" \
    --openssldir="$prefix" \
    shared
make --jobs="$jobs"
# > make test
make install
