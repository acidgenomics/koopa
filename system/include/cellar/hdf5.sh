#!/usr/bin/env bash


usage() {
cat << EOF
usage: install-cellar-hdf5 [--help|-h]

Install HDF5.

details:
    HDF Group website requires registration.

see also:
    - https://www.hdfgroup.org/downloads/hdf5/
    - https://support.hdfgroup.org/ftp/HDF5/releases

note:
    Bash script.
    Updated 2019-09-17.
EOF
}

_koopa_help "$@"

name="hdf5"
version="$(_koopa_variable "$name")"
major_version="$(_koopa_major_version "$version")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"
build_os_string="$(_koopa_build_os_string)"
exe_file="${prefix}/bin/h5cc"

printf "Installing %s %s.\n" "$name" "$version"

(
    rm -frv "$prefix"
    rm -frv "$tmp_dir"
    mkdir -pv "$tmp_dir"
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
    make --jobs="$CPU_COUNT"
    # > make check
    make install
    rm -fr "$tmp_dir"
)

_koopa_link_cellar "$name" "$version"

command -v "$exe_file"
"$exe_file" -showconfig
