#!/usr/bin/env bash
# shellcheck disable=SC2154

file="${name}-${version}.tar.gz"
url="https://cloudflare.cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/${file}"
_koopa_download "$url"
_koopa_extract "$file"
cd "${name}-${version}" || exit 1
./configure --prefix="$prefix"
make --jobs="$jobs"
make install
