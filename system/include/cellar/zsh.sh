#!/usr/bin/env bash

name="zsh"
version="$(_acid_variable "$name")"
prefix="$(_acid_cellar_prefix)/${name}/${version}"
tmp_dir="$(_acid_tmp_dir)/zsh"
build_os_string="$(_acid_build_os_string)"
exe_file="${prefix}/bin/${name}"

_acid_message "Installing ${name} ${version}."

(
    rm -frv "$prefix"
    rm -fr "$tmp_dir"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || exit 1
    url_stem="https://sourceforge.net/projects/zsh/files/zsh"
    file="zsh-${version}.tar.xz"
    _acid_download "${url_stem}/${version}/${file}/download" "$file"
    _acid_extract "$file"
    cd "zsh-${version}" || exit 1
    ./configure \
        --build="$build_os_string" \
        --prefix="$prefix"
    make --jobs="$CPU_COUNT"
    make check
    make test
    make install
    rm -fr "$tmp_dir"
)

_acid_link_cellar "$name" "$version"
_acid_update_shells "$name"

command -v "$exe_file"
"$exe_file" --version
