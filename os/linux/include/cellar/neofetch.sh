#!/usr/bin/env bash
# shellcheck disable=SC2154

file="${version}.tar.gz"
url="https://github.com/dylanaraps/${name}/archive/${file}"
_koopa_download "$url"
_koopa_extract "$file"
cd "${name}-${version}" || exit 1
mkdir -pv "$prefix"
make PREFIX="$prefix" install
