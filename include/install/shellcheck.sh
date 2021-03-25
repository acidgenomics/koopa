#!/usr/bin/env bash
# shellcheck disable=SC2154

if koopa::is_macos
then
    os_id='darwin'
else
    os_id='linux'
fi
arch="$(koopa::arch)"
file="${name}-v${version}.${os_id}.${arch}.tar.xz"
url="https://github.com/koalaman/${name}/releases/download/\
v${version}/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::cp -t "${prefix}/bin" "${name}-v${version}/${name}"
