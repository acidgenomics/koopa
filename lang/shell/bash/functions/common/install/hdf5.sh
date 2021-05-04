#!/usr/bin/env bash

koopa::install_hdf5() { # {{{1
    koopa::install_app \
        --name='hdf5' \
        --name-fancy='HDF5' \
        "$@"
}

koopa:::install_hdf5() { # {{{1
    # """
    # Install HDF5.
    # @note Updated 2021-05-04.
    # """
    local file gfortran_prefix jobs minor_version name prefix url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='hdf5'
    jobs="$(koopa::cpu_count)"
    if koopa::is_macos
    then
        gfortran_prefix='/usr/local/gfortran'
        koopa::assert_is_dir "$gfortran_prefix"
        koopa::add_to_path_start "${gfortran_prefix}/bin"
    fi
    koopa::assert_is_installed gfortran
    minor_version="$(koopa::major_minor_version "$version")"
    file="${name}-${version}.tar.gz"
    url="https://support.hdfgroup.org/ftp/HDF5/releases/\
${name}-${minor_version}/${name}-${version}/src/${file}"
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
    return 0
}
