#!/usr/bin/env bash

name="hdf5"
version="$(_acid_variable "$name")"
major_version="$(_acid_major_version "$version")"
prefix="$(_acid_cellar_prefix)/${name}/${version}"
tmp_dir="$(_acid_tmp_dir)/${name}"
build_os_string="$(_acid_build_os_string)"
exe_file="${prefix}/bin/h5cc"

_acid_message "Installing ${name} ${version}."

(
    rm -frv "$prefix"
    rm -frv "$tmp_dir"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || exit 1
    file="hdf5-${version}.tar.gz"
    url="https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-${major_version}/\
hdf5-${version}/src/${file}"
    _acid_download "$url"
    _acid_extract "$file"
    cd "hdf5-${version}" || exit 1
    ./configure \
        --build="$build_os_string" \
        --prefix="$prefix" \
        --enable-cxx \
        --enable-fortran
    make --jobs="$CPU_COUNT"
    # > make check
    make install
    rm -fr "$tmp_dir"
)

_acid_link_cellar "$name" "$version"

command -v "$exe_file"
"$exe_file" -showconfig
