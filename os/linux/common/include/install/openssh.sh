#!/usr/bin/env bash

koopa::assert_is_linux
file="${name}-${version}.tar.gz"
url="https://cloudflare.cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::cd "${name}-${version}"
./configure --prefix="$prefix"
make --jobs="$jobs"
make install
