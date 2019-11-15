#!/usr/bin/env bash

_koopa_assert_is_installed docbook2x-texi

name="git"
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
    file="v${version}.tar.gz"
    _koopa_download "https://github.com/git/git/archive/${file}"
    _koopa_extract "$file"
    cd "git-${version}" || exit 1
    make configure
    ./configure \
        --build="$build" \
        --prefix="$prefix" \
        --with-openssl="/bin/openssl"
    # This is now erroring on RHEL 7.7:
    # > make --jobs="$CPU_COUNT" all doc info
    # > make install install-doc install-html install-info
    make --jobs="$CPU_COUNT"
    make install
    rm -fr "$tmp_dir"
)

_koopa_link_cellar "$name" "$version"

"$exe_file" --version
command -v "$exe_file"
