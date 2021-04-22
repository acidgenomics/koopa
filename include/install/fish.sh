#!/usr/bin/env bash

# """
# https://github.com/fish-shell/fish-shell/#building
# """

file="fish-${version}.tar.gz"
url="https://github.com/fish-shell/fish-shell/releases/download/\
${version}/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::cd "${name}-${version}"
cmake -DCMAKE_INSTALL_PREFIX="$prefix"
make --jobs="$jobs"
# > make test
make install
if [[ "${link_app:-0}" -eq 1 ]]
then
    koopa::enable_shell "$name"
fi
