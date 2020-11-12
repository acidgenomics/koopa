#!/usr/bin/env bash
# shellcheck disable=SC2154

file="${name}-${version}.tar.xz"
url="https://git.zx2c4.com/${name}/snapshot/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::cd "${name}-${version}"
PREFIX="$prefix" make install
