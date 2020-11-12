#!/usr/bin/env bash
# shellcheck disable=SC2154

koopa::assert_is_installed gfortran

minor_version="$(koopa::major_minor_version "$version")"
file="${name}-${version}.tar.gz"
url="https://support.hdfgroup.org/ftp/HDF5/releases/${name}-${minor_version}/\
${name}-${version}/src/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::cd "${name}-${version}"
./configure \
    --prefix="$prefix" \
    --enable-cxx \
    --enable-fortran
make --jobs="$jobs"
# > make check
make install
