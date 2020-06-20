#!/usr/bin/env bash
# shellcheck disable=SC2154

_koopa_assert_is_installed lua

lua_version="$(_koopa_get_version lua)"
lua_version="$(_koopa_major_minor_version "$lua_version")"

file="${name}-${version}.tar.gz"
url="https://luarocks.org/releases/${file}"
_koopa_download "$url"
_koopa_extract "$file"
cd "${name}-${version}" || exit 1
./configure \
    --prefix="$prefix" \
    --lua-version="$lua_version" \
    --versioned-rocks-dir
make build
make install
