#!/usr/bin/env bash
# shellcheck disable=SC2154

# """
# https://www.freedesktop.org/wiki/Software/pkg-config/
# https://pkg-config.freedesktop.org/releases/
# """

koopa::assert_is_installed cmp diff
file="${name}-${version}.tar.gz"
url="https://${name}.freedesktop.org/releases/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::cd "${name}-${version}"
./configure --prefix="$prefix"
make --jobs="$jobs"
make install
