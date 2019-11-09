#!/usr/bin/env bash

_acid_assert_has_no_args "$@"
_acid_assert_is_installed docbook2x-texi

name="git"
version="$(_acid_variable "$name")"
prefix="$(_acid_cellar_prefix)/${name}/${version}"
tmp_dir="$(_acid_tmp_dir)/${name}"
build_os_string="$(_acid_build_os_string)"
exe_file="${prefix}/bin/${name}"

_acid_message "Installing ${name} ${version}."

(
    rm -frv "$prefix"
    rm -fr "$tmp_dir"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || exit 1
    file="v${version}.tar.gz"
    _acid_download "https://github.com/git/git/archive/${file}"
    _acid_extract "$file"
    cd "git-${version}" || exit 1
    make configure
    ./configure \
        --build="$build_os_string" \
        --prefix="$prefix" \
        --with-openssl="/bin/openssl"
    # This is now erroring on RHEL 7.7:
    # > make --jobs="$CPU_COUNT" all doc info
    # > make install install-doc install-html install-info
    make --jobs="$CPU_COUNT"
    make install
    rm -fr "$tmp_dir"
)

_acid_link_cellar "$name" "$version"

"$exe_file" --version
command -v "$exe_file"
