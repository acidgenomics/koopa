#!/usr/bin/env bash

name="lua"
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
    curl -R -O "http://www.lua.org/ftp/${file}"
    _acid_extract "$file"
    cd "${name}-${version}" || exit 1
    if _acid_is_darwin
    then
        make macosx test
    else
        make linux test
    fi
    make install INSTALL_TOP="$prefix"
    rm -fr "$tmp_dir"
)

_acid_link_cellar "$name" "$version"

"$exe_file" --version
command -v "$exe_file"
