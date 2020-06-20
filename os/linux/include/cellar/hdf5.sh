#!/usr/bin/env bash
# shellcheck disable=SC2154

_koopa_assert_is_installed gfortran

minor_version="$(_koopa_major_minor_version "$version")"
file="${name}-${version}.tar.gz"
url="https://support.hdfgroup.org/ftp/HDF5/releases/${name}-${minor_version}/\
${name}-${version}/src/${file}"
_koopa_download "$url"
_koopa_extract "$file"
cd "${name}-${version}" || exit 1
./configure \
    --prefix="$prefix" \
    --enable-cxx \
    --enable-fortran
make --jobs="$jobs"
# > make check
make install
