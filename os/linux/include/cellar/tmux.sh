#!/usr/bin/env bash
# shellcheck disable=SC2154

file="${name}-${version}.tar.gz"
url="https://github.com/${name}/${name}/releases/download/${version}/${file}"
_koopa_download "$url"
_koopa_extract "$file"
cd "${name}-${version}" || exit 1
./configure --prefix="$prefix"
make --jobs="$jobs"
make install
