#!/usr/bin/env bash

name="genrich"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"
exe_file="${prefix}/bin/${name}"

_koopa_message "Installing ${name} ${version}."

(
    rm -rf "$tmp_dir"
    mkdir -p "$tmp_dir"
    cd "$tmp_dir" || exit 1
    file="v${version}.tar.gz"
    _koopa_download "https://github.com/jsh58/Genrich/archive/${file}"
    _koopa_extract "$file"
    cd "Genrich-${version}" || exit 1
    make
    mkdir -pv "${prefix}/bin"
    cp -frv Genrich "${prefix}/bin/."
    rm -rf "$tmp_dir"
)

_koopa_link_cellar "$name" "$version"

command -v "$exe_file"
"$exe_file" --version
