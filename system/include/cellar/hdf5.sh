#!/usr/bin/env bash

# Install HDF5.
# Modified 2019-06-23.

# See also:
# - https://www.hdfgroup.org/downloads/hdf5/
# - https://support.hdfgroup.org/ftp/HDF5/releases

# Note that website requires registration.

name="hdf5"
version="$(koopa variable "$name")"
prefix="$(koopa cellar-prefix)/${name}/${version}"
tmp_dir="$(koopa tmp-dir)/${name}"
build_os_string="$(koopa build-os-string)"
exe_file="${prefix}/bin/h5dump"

major_version="$(echo "$version" | cut -d '.' -f 1-2)"

printf "Installing %s %s.\n" "$name" "$version"

(
    rm -rf "$tmp_dir"
    mkdir -p "$tmp_dir"
    cd "$tmp_dir" || exit 1
    file="hdf5-${version}.tar.gz"
    url="https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-${major_version}/hdf5-${version}/src/${file}"
    wget "$url"
    tar -xzvf "$file"
    cd "hdf5-${version}" || exit 1
    ./configure \
        --build="$build_os_string" \
        --prefix="$prefix" \
        --enable-cxx \
        --enable-fortran
    make
    # > make check
    make install
    rm -rf "$tmp_dir"
)

link-cellar "$name" "$version"

command -v "$exe_file"
"$exe_file" --version
