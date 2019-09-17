#!/usr/bin/env bash

# Install GNU Scientific Library (GSL).
# Updated 2019-09-17.

# See also:
# - https://www.gnu.org/software/gsl/

_koopa_assert_has_no_environments

name="gsl"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"
build_os_string="$(_koopa_build_os_string)"
exe_file="${prefix}/bin/gsl-config"

printf "Installing %s %s.\n" "$name" "$version"

(
    rm -frv "$prefix"
    rm -fr "$tmp_dir"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || exit 1
    wget "http://mirror.keystealth.org/gnu/gsl/gsl-${version}.tar.gz"
    tar xzvf "gsl-${version}.tar.gz"
    cd "gsl-${version}" || exit 1
    ./configure \
        --build="$build_os_string" \
        --prefix="$prefix"
    make --jobs="$CPU_COUNT"
    make check
    make install
    rm -fr "$tmp_dir"
)

link-cellar "$name" "$version"

command -v "$exe_file"
"$exe_file" --version
