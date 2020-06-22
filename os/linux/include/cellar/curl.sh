#!/usr/bin/env bash
# shellcheck disable=SC2154

# """
# https://curl.haxx.se/docs/install.html
# """

file="${name}-${version}.tar.xz"
version2="${version//./_}"
url="https://github.com/${name}/${name}/releases/download/\
${name}-${version2}/${file}"
_koopa_download "$url"
_koopa_extract "$file"
cd "${name}-${version}" || exit 1
./configure --prefix="$prefix"
make --jobs="$jobs"
# > make test
make install
