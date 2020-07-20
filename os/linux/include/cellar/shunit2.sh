#!/usr/bin/env bash
# shellcheck disable=SC2154

file="v${version}.tar.gz"
url="https://github.com/kward/${name}/archive/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::cd "${name}-${version}"
koopa::mkdir "${prefix}/bin"
koopa::sys_set_permissions -r "$prefix"
cp -a "$name" -t "${prefix}/bin/"
