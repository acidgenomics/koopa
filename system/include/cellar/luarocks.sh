#!/usr/bin/env bash

_acid_assert_is_installed lua

name="luarocks"
version="$(_acid_variable "$name")"
prefix="$(_acid_cellar_prefix)/${name}/${version}"
tmp_dir="$(_acid_tmp_dir)/${name}"
exe_file="${prefix}/bin/${name}"

_acid_message "Installing ${name} ${version}."

(
    rm -frv "$prefix"
    rm -fr "$tmp_dir"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || exit 1
    file="${name}-${version}.tar.gz"
    url="https://luarocks.org/releases/${file}"
    _acid_download "$url"
    _acid_extract "$file"
    cd "${name}-${version}" || exit 1
    ./configure --prefix="$prefix"
    make build
    make install
    rm -fr "$tmp_dir"
)

_acid_link_cellar "$name" "$version"

# > build_prefix="$(_acid_build_prefix)
# > export LUAROCKS_PREFIX="$build_prefix"

# Install Lmod dependencies.
luarocks install luaposix
luarocks install luafilesystem

_acid_link_cellar "$name" "$version"

"$exe_file" --version
command -v "$exe_file"

lua -e 'print(package.path)'
