#!/usr/bin/env bash

name="rmate"
version="$(_acid_variable "$name")"
prefix="$(_acid_cellar_prefix)/${name}/${version}"
tmp_dir="$(_acid_tmp_dir)/${name}"
exe_file="${prefix}/bin/${name}"

(
    rm -frv "$prefix"
    rm -frv "$tmp_dir"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || exit 1
    file="v${version}.tar.gz"
    url="https://github.com/aurora/rmate/archive/${file}"
    _acid_download "$url"
    _acid_extract "$file"
    cd "rmate-${version}" || exit 1
    chmod a+x rmate
    cp rmate "${prefix}/bin"
)

_acid_link_cellar "$name" "$version"

command -v "$exe_file"
"$exe_file" --version
