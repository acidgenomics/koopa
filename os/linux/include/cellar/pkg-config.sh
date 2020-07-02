#!/usr/bin/env bash
# shellcheck disable=SC2154

# """
# https://www.freedesktop.org/wiki/Software/pkg-config/
# https://pkg-config.freedesktop.org/releases/
# """

_koopa_assert_is_installed cmp diff
file="${name}-${version}.tar.gz"
url="https://${name}.freedesktop.org/releases/${file}"
_koopa_download "$url"
_koopa_extract "$file"
cd "${name}-${version}" || exit 1
./configure --prefix="$prefix"
make --jobs="$jobs"
make install
