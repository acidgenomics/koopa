#!/usr/bin/env bash

main() {
    # """
    # Install HDF5.
    # @note Updated 2023-06-27.
    #
    # Using gcc here for gfortran.
    #
    # @seealso
    # - https://www.hdfgroup.org/downloads/hdf5/source-code/
    # - https://docs.hdfgroup.org/archive/support/HDF5/release/cmakebuild.html
    # - https://docs.hdfgroup.org/archive/support/HDF5/release/chgcmkbuild.html
    # - https://github.com/conda-forge/hdf5-feedstock
    # - https://formulae.brew.sh/formula/hdf5
    # """
    local -A dict
    local -a conf_args deps
    deps=('zlib' 'gcc' 'libaec')
    koopa_activate_app "${deps[@]}"
    dict['libaec']="$(koopa_app_prefix 'libaec')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['zlib']="$(koopa_app_prefix 'zlib')"
    dict['maj_min_ver']="$(koopa_major_minor_version "${dict['version']}")"
    dict['mmp_ver']="$(koopa_major_minor_patch_version "${dict['version']}")"
    conf_args=(
        '--disable-dependency-tracking'
        '--disable-silent-rules'
        '--disable-static'
        '--enable-build-mode=production'
        '--enable-cxx'
        '--enable-fortran'
        "--prefix=${dict['prefix']}"
        "--with-szlib=${dict['libaec']}"
        "--with-zlib=${dict['zlib']}"
    )
    dict['url']="https://support.hdfgroup.org/ftp/HDF5/releases/\
hdf5-${dict['maj_min_ver']}/hdf5-${dict['mmp_ver']}/src/\
hdf5-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
