#!/usr/bin/env bash
set -Eeu -o pipefail

name="gsl"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"
build="$(_koopa_make_build_string)"
jobs="$(_koopa_cpu_count)"
exe_file="${prefix}/bin/gsl-config"

_koopa_message "Installing ${name} ${version}."

(
    _koopa_cd_tmp_dir "$tmp_dir"
    file="gsl-${version}.tar.gz"
    url="http://mirror.keystealth.org/gnu/gsl/${file}"
    _koopa_download "$url"
    _koopa_extract "$file"
    cd "gsl-${version}" || exit 1
    ./configure \
        --build="$build" \
        --prefix="$prefix"
    make --jobs="$jobs"
    make check
    make install
    rm -fr "$tmp_dir"
)

_koopa_link_cellar "$name" "$version"

command -v "$exe_file"
"$exe_file" --version
