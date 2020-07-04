#!/usr/bin/env bash
# shellcheck disable=SC2154

file="v${version}.tar.gz"
url="https://github.com/kward/${name}/archive/${file}"
koopa::download "$url"
koopa::extract "$file"
cd "${name}-${version}" || exit 1
koopa::mkdir "${prefix}/bin"
koopa::set_permissions --recursive "$prefix"
cp -a "$name" -t "${prefix}/bin/"
