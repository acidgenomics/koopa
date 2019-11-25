#!/usr/bin/env bash
set -Eeu -o pipefail

name="hdf5"
version="$(_koopa_variable "$name")"
major_version="$(_koopa_major_version "$version")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"
build="$(_koopa_make_build_string)"
jobs="$(_koopa_cpu_count)"

_koopa_message "Installing ${name} ${version}."

(
    _koopa_cd_tmp_dir "$tmp_dir"
    file="hdf5-${version}.tar.gz"
    url="https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-${major_version}/\
hdf5-${version}/src/${file}"
    _koopa_download "$url"
    _koopa_extract "$file"
    cd "hdf5-${version}" || exit 1
    ./configure \
        --build="$build" \
        --prefix="$prefix" \
        --enable-cxx \
        --enable-fortran
    make --jobs="$jobs"
    # > make check
    make install
    rm -fr "$tmp_dir"
)

_koopa_link_cellar "$name" "$version"
