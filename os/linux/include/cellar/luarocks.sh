#!/usr/bin/env bash
# shellcheck disable=SC2154

koopa::assert_is_installed lua

lua_version="$(koopa::get_version lua)"
lua_version="$(koopa::major_minor_version "$lua_version")"

file="${name}-${version}.tar.gz"
url="https://luarocks.org/releases/${file}"
koopa::download "$url"
koopa::extract "$file"
cd "${name}-${version}" || exit 1
./configure \
    --prefix="$prefix" \
    --lua-version="$lua_version" \
    --versioned-rocks-dir
make build
make install
