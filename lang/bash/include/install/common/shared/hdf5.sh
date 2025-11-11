#!/usr/bin/env bash

main() {
    # """
    # Install HDF5.
    # @note Updated 2025-11-11.
    #
    # @seealso
    # - https://github.com/HDFGroup/hdf5/
    # - https://www.hdfgroup.org/downloads/hdf5/source-code/
    # - https://docs.hdfgroup.org/archive/support/HDF5/release/cmakebuild.html
    # - https://docs.hdfgroup.org/archive/support/HDF5/release/chgcmkbuild.html
    # - https://github.com/conda-forge/hdf5-feedstock
    # - https://formulae.brew.sh/formula/hdf5
    # - https://github.com/mokus0/bindings-hdf5/blob/master/doc/hdf5.pc
    # """
    local -A cmake dict
    local -a cmake_args deps
    deps=('libaec' 'zlib')
    koopa_activate_app "${deps[@]}"
    dict['libaec']="$(koopa_app_prefix 'libaec')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['shared_ext']="$(koopa_shared_ext)"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['zlib']="$(koopa_app_prefix 'zlib')"
    dict['version2']="$( \
        koopa_gsub \
            --fixed \
            --pattern='-' \
            --replacement='.' \
            "${dict['version']}" \
    )"
    dict['url']="https://github.com/HDFGroup/hdf5/releases/download/\
hdf5_${dict['version2']}/hdf5-${dict['version']}.tar.gz"
    cmake['zlib_include_dir']="${dict['zlib']}/include"
    cmake['zlib_library']="${dict['zlib']}/lib/libz.${dict['shared_ext']}"
    koopa_assert_is_dir \
        "${cmake['zlib_include_dir']}"
    koopa_assert_is_file \
        "${cmake['zlib_library']}"
    cmake_args=(
        # > '-DHDF5_BUILD_FORTRAN:BOOL=ON'
        # > '-DHDF5_ENABLE_NONSTANDARD_FEATURE_FLOAT16:BOOL=OFF'
        # > '-DHDF5_ENABLE_SZIP_SUPPORT:BOOL=ON'
        # > '-DHDF5_INSTALL_CMAKE_DIR=lib/cmake/hdf5'
        # > '-DHDF5_USE_GNU_DIRS:BOOL=ON'
        '-DHDF5_BUILD_CPP_LIB:BOOL=ON'
        "-DZLIB_INCLUDE_DIR=${cmake['zlib_include_dir']}"
        "-DZLIB_LIBRARY=${cmake['zlib_library']}"
    )
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}
