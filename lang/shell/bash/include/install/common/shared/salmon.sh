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
    # - https://cmake.org/cmake/help/latest/module/FindICU.html
    # - https://cmake.org/cmake/help/latest/module/FindLibLZMA.html
    # """
    local -A cmake dict
    local -a cmake_args deps
    deps=(
        'boost'
        'bzip'
        'cereal'
        'icu4c'
        'jemalloc'
        'staden-io-lib'
        'tbb'
        'xz'
        'zlib'
    )
    koopa_activate_app "${deps[@]}"
    dict['boost']="$(koopa_app_prefix 'boost')"
    dict['cereal']="$(koopa_app_prefix 'cereal')"
    dict['icu4c']="$(koopa_app_prefix 'icu4c')"
    dict['jemalloc']="$(koopa_app_prefix 'jemalloc')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['shared_ext']="$(koopa_shared_ext)"
    dict['tbb']="$(koopa_app_prefix 'tbb')"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['xz']="$(koopa_app_prefix 'xz')"
    dict['zlib']="$(koopa_app_prefix 'zlib')"
    cmake['boost_include_dir']="${dict['boost']}/include"
    cmake['bzip2_include_dir']="${dict['bzip2']}/include"
    cmake['bzip2_libraries']="${dict['bzip2']}/lib/libbz2.${dict['shared_ext']}"
    cmake['cereal_dir']="${dict['cereal']}/lib/cmake/cereal"
    cmake['icu_root']="${dict['icurc']}"
    cmake['jemalloc_include_dir']="${dict['jemalloc']}/include"
    cmake['jemalloc_libraries']="${dict['jemalloc']}/lib/\
libjemalloc.${dict['shared_ext']}"
    cmake['liblzma_include_dirs']="${dict['xz']}/include"
    cmake['liblzma_libraries']="${dict['xz']}/lib/liblzma.${dict['shared_ext']}"
    cmake['tbb_include_dirs']="${dict['tbb']}/include"
    cmake['tbb_libraries']="${dict['tbb']}/lib/libtbb.${dict['shared_ext']}"
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
        # Potentially useful:
        # * -DICU_INCLUDE_DIRS
        # * -DICU_LIBRARIES
        # * -DLIB_GFF_INCLUDE_DIR
        # * -DLIB_GFF_LIBRARY_DIR
        "-DBZIP2_INCLUDE_DIR=${cmake['bzip2_include_dir']}"
        "-DBZIP2_LIBRARIES=${cmake['bzip2_libraries']}"
        "-DBoost_INCLUDE_DIR=${cmake['boost_include_dir']}"
        "-DICU_ROOT=${cmake['icu_root']}"
        "-DZLIB_INCLUDE_DIR=${cmake['zlib_include_dir']}"
        "-DZLIB_LIBRARY=${cmake['zlib_library']}"
        "-Dcereal_DIR:PATH=${cmake['cereal_dir']}"
        "-DJEMALLOC_INCLUDE_DIR=${cmake['jemalloc_include_dir']}"
        "-DJEMALLOC_LIBRARIES=${cmake['jemalloc_libraries']}"
        "-DLIBLZMA_INCLUDE_DIRS=${cmake['liblzma_include_dirs']}"
        "-DLIBLZMA_LIBRARIES=${cmake['liblzma_libraries']}"
        "-DSTADEN_INCLUDE_DIR=FIXME"
        "-DSTADEN_LIBRARIES=FIXME"
        "-DTBB_INCLUDE_DIRS=${cmake['tbb_include_dirs']}"
        "-DTBB_LIBRARIES=${cmake['tbb_libraries']}"
    )
    dict['url']="https://github.com/COMBINE-lab/salmon/archive/refs/tags/\
v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}
