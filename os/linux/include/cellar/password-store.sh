#!/usr/bin/env bash
# shellcheck disable=SC2154

file="${name}-${version}.tar.xz"
url="https://git.zx2c4.com/${name}/snapshot/${file}"
_koopa_download "$url"
_koopa_extract "$file"
cd "${name}-${version}" || exit 1
PREFIX="$prefix" make install
