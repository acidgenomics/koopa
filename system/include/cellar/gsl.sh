#!/usr/bin/env bash

# Install GNU Scientific Library (GSL).
# Modified 2019-06-23.

# See also:
# - https://www.gnu.org/software/gsl/

name="gsl"
version="$(koopa variable "$name")"
prefix="$(koopa cellar-prefix)/${name}/${version}"
tmp_dir="$(koopa tmp-dir)/${name}"
build_os_string="$(koopa build-os-string)"
exe_file="${prefix}/bin/gsl-config"

printf "Installing %s %s.\n" "$name" "$version"

(
    rm -rf "$tmp_dir"
    mkdir -p "$tmp_dir"
    cd "$tmp_dir" || exit 1
    wget "http://mirror.keystealth.org/gnu/gsl/gsl-${version}.tar.gz"
    tar xzvf "gsl-${version}.tar.gz"
    cd "gsl-${version}" || exit 1
    ./configure \
        --build="$build_os_string" \
        --prefix="$prefix"
    make
    make check
    make install
    rm -rf "$tmp_dir"
)

link-cellar "$name" "$version"

command -v "$exe_file"
"$exe_file" --version
