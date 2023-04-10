#!/usr/bin/env bash

main() {
    # """
    # Install HDF5.
    # @note Updated 2023-04-10.
    #
    # Using gcc here for gfortran.
    # """
    local -A dict
    local -a conf_args
    koopa_activate_app 'zlib' 'gcc'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['zlib']="$(koopa_app_prefix 'zlib')"
    dict['maj_min_ver']="$(koopa_major_minor_version "${dict['version']}")"
    conf_args=(
        '--disable-dependency-tracking'
        '--disable-silent-rules'
        '--enable-build-mode=production'
        '--enable-cxx'
        '--enable-fortran'
        "--prefix=${dict['prefix']}"
        "--with-zlib=${dict['zlib']}"
    )
    dict['url']="https://support.hdfgroup.org/ftp/HDF5/releases/\
hdf5-${dict['maj_min_ver']}/hdf5-${dict['version']}/src/\
hdf5-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
