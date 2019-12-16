#!/usr/bin/env bash
set -Eeu -o pipefail

_koopa_assert_is_installed lua

name="luarocks"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"

lua_version="$(_koopa_current_version lua)"
lua_version="$(_koopa_minor_version "$lua_version")"

_koopa_message "Installing ${name} ${version} for lua ${lua_version}."

(
    _koopa_cd_tmp_dir "$tmp_dir"
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
    rm -fr "$tmp_dir"
)

_koopa_link_cellar "$name" "$version"

# > build_prefix="$(_koopa_make_prefix)
# > export LUAROCKS_PREFIX="$build_prefix"

# Install Lmod dependencies.
luarocks install luaposix
luarocks install luafilesystem

_koopa_link_cellar "$name" "$version"

# > lua -e 'print(package.path)'
