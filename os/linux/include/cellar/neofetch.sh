#!/usr/bin/env bash
# shellcheck disable=SC2154

file="${version}.tar.gz"
url="https://github.com/dylanaraps/${name}/archive/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::cd "${name}-${version}"
mkdir -pv "$prefix"
make PREFIX="$prefix" install
