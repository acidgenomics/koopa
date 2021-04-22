#!/usr/bin/env bash
# 
# """
# https://curl.haxx.se/docs/install.html
# """

file="${name}-${version}.tar.xz"
version2="${version//./_}"
url="https://github.com/${name}/${name}/releases/download/\
${name}-${version2}/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::cd "${name}-${version}"
./configure --prefix="$prefix"
make --jobs="$jobs"
# > make test
make install
