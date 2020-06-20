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

_koopa_h2 "Installing Lmod dependencies."
# > build_prefix="$(_koopa_make_prefix)
# > export LUAROCKS_PREFIX="$build_prefix"
luarocks_exe="${prefix}/bin/luarocks"
"$luarocks_exe" install luaposix
"$luarocks_exe" install luafilesystem
