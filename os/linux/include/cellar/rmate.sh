#!/usr/bin/env bash
# shellcheck disable=SC2154

file="v${version}.tar.gz"
url="https://github.com/aurora/${name}/archive/${file}"
_koopa_download "$url"
_koopa_extract "$file"
cd "${name}-${version}" || exit 1
chmod a+x rmate
mkdir -p "${prefix}/bin"
cp rmate -t "${prefix}/bin"
