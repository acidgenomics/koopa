#!/usr/bin/env bash

name="zsh"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"
build="$(_koopa_make_build_string)"
exe_file="${prefix}/bin/${name}"

_koopa_message "Installing ${name} ${version}."

(
    rm -fr "$tmp_dir"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || exit 1
    url_stem="https://sourceforge.net/projects/zsh/files/zsh"
    file="zsh-${version}.tar.xz"
    _koopa_download "${url_stem}/${version}/${file}/download" "$file"
    _koopa_extract "$file"
    cd "zsh-${version}" || exit 1
    ./configure \
        --build="$build" \
        --prefix="$prefix"
    make --jobs="$CPU_COUNT"
    make check
    make test
    make install
    rm -fr "$tmp_dir"
)

_koopa_link_cellar "$name" "$version"
_koopa_update_shells "$name"

command -v "$exe_file"
"$exe_file" --version
