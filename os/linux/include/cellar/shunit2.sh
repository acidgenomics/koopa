#!/usr/bin/env bash
# shellcheck disable=SC2154

file="v${version}.tar.gz"
url="https://github.com/kward/${name}/archive/${file}"
_koopa_download "$url"
_koopa_extract "$file"
cd "${name}-${version}" || exit 1
_koopa_mkdir "${prefix}/bin"
_koopa_set_permissions --recursive "$prefix"
cp --archive "$name" -t "${prefix}/bin/"
