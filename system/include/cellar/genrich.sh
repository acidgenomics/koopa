#!/usr/bin/env bash

name="genrich"
version="$(_acid_variable "$name")"
prefix="$(_acid_cellar_prefix)/${name}/${version}"
tmp_dir="$(_acid_tmp_dir)/${name}"
exe_file="${prefix}/bin/${name}"

_acid_message "Installing ${name} ${version}."

(
    rm -rf "$tmp_dir"
    mkdir -p "$tmp_dir"
    cd "$tmp_dir" || exit 1
    file="v${version}.tar.gz"
    _acid_download "https://github.com/jsh58/Genrich/archive/${file}"
    _acid_extract "$file"
    cd "Genrich-${version}" || exit 1
    make
    mkdir -pv "${prefix}/bin"
    cp -frv Genrich "${prefix}/bin/."
    rm -rf "$tmp_dir"
)

_acid_link_cellar "$name" "$version"

command -v "$exe_file"
"$exe_file" --version
