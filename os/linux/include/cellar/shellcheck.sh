#!/usr/bin/env bash
# shellcheck disable=SC2154

file="${name}-v${version}.linux.x86_64.tar.xz"
# Previous URL, until 2020-03-13:
# > url="https://storage.googleapis.com/${name}/${file}"
# See https://github.com/koalaman/shellcheck/issues/1871 for details.
url="https://github.com/koalaman/${name}/releases/download/\
v${version}/${file}"
_koopa_download "$url"
_koopa_extract "$file"
mkdir -pv "${prefix}/bin"
cp "${name}-v${version}/${name}" "${prefix}/bin"

