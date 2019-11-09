#!/usr/bin/env bash

_acid_assert_has_no_args "$@"

name="gsl"
version="$(_acid_variable "$name")"
prefix="$(_acid_cellar_prefix)/${name}/${version}"
tmp_dir="$(_acid_tmp_dir)/${name}"
build_os_string="$(_acid_build_os_string)"
exe_file="${prefix}/bin/gsl-config"

_acid_message "Installing ${name} ${version}."

(
    rm -frv "$prefix"
    rm -fr "$tmp_dir"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || exit 1
    file="gsl-${version}.tar.gz"
    url="http://mirror.keystealth.org/gnu/gsl/${file}"
    _acid_download "$url"
    _acid_extract "$file"
    cd "gsl-${version}" || exit 1
    ./configure \
        --build="$build_os_string" \
        --prefix="$prefix"
    make --jobs="$CPU_COUNT"
    make check
    make install
    rm -fr "$tmp_dir"
)

_acid_link_cellar "$name" "$version"

command -v "$exe_file"
"$exe_file" --version
