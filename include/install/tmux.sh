#!/usr/bin/env bash
# shellcheck disable=SC2154

file="${name}-${version}.tar.gz"
url="https://github.com/${name}/${name}/releases/download/${version}/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::cd "${name}-${version}"
./configure --prefix="$prefix"
make --jobs="$jobs"
make install
