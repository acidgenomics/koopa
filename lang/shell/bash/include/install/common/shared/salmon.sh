#!/usr/bin/env bash

# FIXME Need to add dependencies for salmon:
#
# FIXME Need bzip2
# FIXME Need libiconv
# FIXME Need lzma
# FIXME Need to locate curl
#
#    - boost-cpp
#    - bzip2
#    - icu 
#    - jemalloc >=5.1.0
#    - tbb >=2021.4.0
#    - tbb-devel >=2021.4.0
#    - unzip
#    - zlib
#
# -- Could NOT find Jemalloc (missing: JEMALLOC_LIBRARY JEMALLOC_INCLUDE_DIR)
# -- Could NOT find LibLZMA (missing: LIBLZMA_INCLUDE_DIR)
# -- Could NOT find PkgConfig (missing: PKG_CONFIG_EXECUTABLE)
# -- Could NOT find TBB (missing: TBB_DIR)
# -- Could NOT find cereal (missing: CEREAL_INCLUDE_DIR)
# -- Could NOT find libgff (missing: libgff_DIR)
# HTSCODEC_LIBRARY:FILEPATH=HTSCODEC_LIBRARY-NOTFOUND
# TBB_DIR:PATH=TBB_DIR-NOTFOUND
# libgff_DIR:PATH=libgff_DIR-NOTFOUND
# LIBSTADEN?

main() {
    # """
    # Install salmon.
    # @note Updated 2023-05-01.
    #
    # @seealso
    # - https://github.com/COMBINE-lab/salmon/
    # - https://github.com/bioconda/bioconda-recipes/tree/master/recipes/salmon
    # """
    local -A cmake dict
    local -a cmake_args deps
    deps=(
        'boost'
        'bzip'
        'cereal'
        'icu4c'
        'jemalloc'
        'libgff'
        'libstaden'
        'tbb'
        'xz'
        'zlib'
    )
    koopa_activate_app "${deps[@]}"
    dict['boost']="$(koopa_app_prefix 'boost')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['shared_ext']="$(koopa_shared_ext)"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['zlib']="$(koopa_app_prefix 'zlib')"
    cmake['boost_include_dir']="${dict['boost']}/include"
    cmake['zlib_include_dir']="${dict['zlib']}/include"
    cmake['zlib_library']="${dict['zlib']}/lib/libz.${dict['shared_ext']}"
    cmake_args=(
        # Build options --------------------------------------------------------
        '-DBoost_NO_BOOST_CMAKE=ON'
        '-DFETCHED_PUFFERFISH=TRUE'
        '-DFETCH_BOOST=FALSE'
        '-DNO_IPO=TRUE'
        '-DUSE_SHARED_LIBS=ON'
        # Dependency paths -----------------------------------------------------
        "-DBoost_INCLUDE_DIR=${cmake['boost_include_dir']}"
        "-DZLIB_INCLUDE_DIR=${cmake['zlib_include_dir']}"
        "-DZLIB_LIBRARY=${cmake['zlib_library']}"
        # > FIXME -DBZIP2_LIBRARIES
        # > FIXME -DICU_INCLUDE_DIRS
        # > FIXME -DICU_LIBRARIES
        # > FIXME CEREAL
        # > FIXME JEMALLOC
        # > FIXME LIBGFF
        # > FIXME LIBLZMA (xz)
        # > FIXME LIBSTADEN
        # > FIXME TBB
    )
    dict['url']="https://github.com/COMBINE-lab/salmon/archive/refs/tags/\
v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}
