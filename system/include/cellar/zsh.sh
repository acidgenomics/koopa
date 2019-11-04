#!/usr/bin/env bash

_koopa_help "$@"
_koopa_assert_has_no_args "$@"

name="zsh"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/zsh"
build_os_string="$(_koopa_build_os_string)"
exe_file="${prefix}/bin/${name}"

_koopa_message "Installing ${name} ${version}."

(
    rm -frv "$prefix"
    rm -fr "$tmp_dir"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || exit 1
    file="zsh-${version}.tar.xz"
    wget -O "$file" "https://sourceforge.net/projects/zsh/files/\
zsh/${version}/${file}/download"
    _koopa_extract "$file"
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

_koopa_link_cellar "$name" "$version"
_koopa_update_shells "$name"

command -v "$exe_file"
"$exe_file" --version
