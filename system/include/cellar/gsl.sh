#!/usr/bin/env bash

name="gsl"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"
build_os_string="$(_koopa_build_os_string)"
exe_file="${prefix}/bin/gsl-config"

_koopa_message "Installing ${name} ${version}."

(
    rm -frv "$prefix"
    rm -fr "$tmp_dir"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || exit 1
    file="gsl-${version}.tar.gz"
    url="http://mirror.keystealth.org/gnu/gsl/${file}"
    _koopa_download "$url"
    _koopa_extract "$file"
    cd "gsl-${version}" || exit 1
    ./configure \
        --build="$build_os_string" \
        --prefix="$prefix"
    make --jobs="$CPU_COUNT"
    make check
    make install
    rm -fr "$tmp_dir"
)

_koopa_link_cellar "$name" "$version"

command -v "$exe_file"
"$exe_file" --version
