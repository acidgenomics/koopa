#!/usr/bin/env bash

install_from_conda() {
    koopa_install_conda_package
}

install_from_source() {
    # """
    # Install salmon from source.
    # @note Updated 2024-07-15.
    #
    # @seealso
    # - https://github.com/COMBINE-lab/salmon/
    # - https://github.com/bioconda/bioconda-recipes/tree/master/recipes/salmon
    # - https://cmake.org/cmake/help/latest/module/FindICU.html
    # - https://cmake.org/cmake/help/latest/module/FindLibLZMA.html
    # - https://github.com/COMBINE-lab/salmon/issues/664
    # """
    local -A app cmake dict
    local -a build_deps cmake_args deps
    build_deps=('patch' 'pkg-config')
    ! koopa_is_macos && deps+=('bzip2')
    deps+=(
        'boost'
        'cereal'
        'curl'
        'icu4c'
        'jemalloc'
        'libiconv'
        'staden-io-lib'
        'tbb'
        'xz'
        'zlib'
    )
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    app['patch']="$(koopa_locate_patch)"
    app['pkg_config']="$(koopa_locate_pkg_config --realpath)"
    koopa_assert_is_executable "${app[@]}"
    dict['curl']="$(koopa_app_prefix 'curl')"
    dict['icu4c']="$(koopa_app_prefix 'icu4c')"
    dict['jemalloc']="$(koopa_app_prefix 'jemalloc')"
    dict['libiconv']="$(koopa_app_prefix 'libiconv')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['shared_ext']="$(koopa_shared_ext)"
    dict['staden_io_lib']="$(koopa_app_prefix 'staden-io-lib')"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['xz']="$(koopa_app_prefix 'xz')"
    dict['zlib']="$(koopa_app_prefix 'zlib')"
    cmake['curl_include_dir']="${dict['curl']}/include"
    cmake['curl_library']="${dict['curl']}/lib/libcurl.${dict['shared_ext']}"
    cmake['htscodec_library']="${dict['staden_io_lib']}/lib/libhtscodecs.a"
    cmake['iconv_include_dir']="${dict['libiconv']}/include"
    cmake['iconv_library']="${dict['libiconv']}/lib/\
libiconv.${dict['shared_ext']}"
    cmake['icu_root']="${dict['icu4c']}"
    cmake['jemalloc_include_dir']="${dict['jemalloc']}/include"
    cmake['jemalloc_library']="${dict['jemalloc']}/lib/\
libjemalloc.${dict['shared_ext']}"
    cmake['liblzma_include_dir']="${dict['xz']}/include"
    cmake['liblzma_library']="${dict['xz']}/lib/liblzma.${dict['shared_ext']}"
    cmake['pkg_config_executable']="${app['pkg_config']}"
    cmake['staden_include_dir']="${dict['staden_io_lib']}/include"
    cmake['staden_library']="${dict['staden_io_lib']}/lib/\
libstaden-read.${dict['shared_ext']}"
    cmake['staden_version']="$(koopa_app_version 'staden-io-lib')"
    cmake['zlib_include_dir']="${dict['zlib']}/include"
    cmake['zlib_library']="${dict['zlib']}/lib/libz.${dict['shared_ext']}"
    cmake_args+=(
        # Build options --------------------------------------------------------
        '-DNO_IPO=TRUE'
        '-DUSE_SHARED_LIBS=ON'
        # Dependency paths -----------------------------------------------------
        "-DCURL_INCLUDE_DIR=${cmake['curl_include_dir']}"
        "-DCURL_LIBRARY=${cmake['curl_library']}"
        "-DHTSCODEC_LIBRARY=${cmake['htscodec_library']}"
        "-DICU_ROOT=${cmake['icu_root']}"
        "-DIconv_INCLUDE_DIR=${cmake['iconv_include_dir']}"
        "-DIconv_LIBRARY=${cmake['iconv_library']}"
        "-DJEMALLOC_INCLUDE_DIR=${cmake['jemalloc_include_dir']}"
        "-DJEMALLOC_LIBRARY=${cmake['jemalloc_library']}"
        "-DLIBLZMA_INCLUDE_DIR=${cmake['liblzma_include_dir']}"
        "-DLIBLZMA_LIBRARY=${cmake['liblzma_library']}"
        "-DPKG_CONFIG_EXECUTABLE=${cmake['pkg_config_executable']}"
        "-DSTADEN_INCLUDE_DIR=${cmake['staden_include_dir']}"
        "-DSTADEN_LIBRARY=${cmake['staden_library']}"
        "-DSTADEN_VERSION=${cmake['staden_version']}"
        "-DZLIB_INCLUDE_DIR=${cmake['zlib_include_dir']}"
        "-DZLIB_LIBRARY=${cmake['zlib_library']}"
    )
    if ! koopa_is_macos
    then
        dict['bzip2']="$(koopa_app_prefix 'bzip2')"
        cmake['bzip2_include_dir']="${dict['bzip2']}/include"
        cmake['bzip2_libraries']="${dict['bzip2']}/lib/\
libbz2.${dict['shared_ext']}"
        cmake_args+=(
            # Dependency paths -------------------------------------------------
            "-DBZIP2_INCLUDE_DIR=${cmake['bzip2_include_dir']}"
            "-DBZIP2_LIBRARIES=${cmake['bzip2_libraries']}"
        )
    fi
    dict['url']="https://github.com/COMBINE-lab/salmon/archive/refs/tags/\
v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    dict['patch_prefix']="$(koopa_patch_prefix)/common/salmon"
    koopa_assert_is_dir "${dict['patch_prefix']}"
    dict['patch_file']="${dict['patch_prefix']}/staden.patch"
    "${app['patch']}" \
        --unified \
        --verbose \
        'cmake/Modules/Findlibstadenio.cmake' \
        "${dict['patch_file']}"
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    app['salmon']="${dict['prefix']}/bin/salmon"
    koopa_assert_is_executable "${app['salmon']}"
    "${app['salmon']}" --version
    return 0
}

main() {
    if koopa_is_aarch64
    then
        install_from_source "$@"
    else
        install_from_conda "$@"
    fi
    return 0
}
