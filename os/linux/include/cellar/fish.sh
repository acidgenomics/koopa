#!/usr/bin/env bash
# shellcheck disable=SC2154

# """
# https://github.com/fish-shell/fish-shell/#building
# """

file="fish-${version}.tar.gz"
url="https://github.com/fish-shell/fish-shell/releases/download/\
${version}/${file}"
_koopa_download "$url"
_koopa_extract "$file"
cd "${name}-${version}" || exit 1
cmake -DCMAKE_INSTALL_PREFIX="$prefix"
make --jobs="$jobs"
# > make test
make install

_koopa_enable_shell "$name"
