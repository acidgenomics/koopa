#!/usr/bin/env bash
# shellcheck disable=SC2154

_koopa_assert_is_installed makeinfo  # texinfo

file="${name}-${version}.tar.xz"
url="${gnu_mirror}/${name}/${file}"
_koopa_download "$url"
_koopa_extract "$file"
cd "${name}-${version}" || exit 1
./configure --prefix="$prefix"
make --jobs="$jobs"
# > make check
make install
