#!/usr/bin/env bash
# shellcheck disable=SC2154

file="${name}-${version}-stable.tar.gz"
url="https://github.com/${name}/${name}/releases/download/\
release-${version}-stable/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::cd "${name}-${version}"
./configure --prefix="$prefix"
make --jobs="$jobs"
# > make check
make install
