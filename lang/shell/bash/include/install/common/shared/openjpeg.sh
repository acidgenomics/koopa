#!/usr/bin/env bash

main() {
    # """
    # Install openjpeg.
    # @note Updated 2023-05-11.
    #
    # @seealso
    # - https://github.com/uclouvain/openjpeg
    # - https://github.com/conda-forge/openjpeg-feedstock
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     openjpeg.rb
    # - https://ports.macports.org/port/openjpeg/details/
    # """
    local -A cmake dict
    local -a cmake_args
    koopa_activate_app --build-only 'pkg-config'
    koopa_activate_app \
        'zlib' \
        'zstd' \
        'libjpeg-turbo' \
        'libpng' \
        'libtiff'
    dict['libpng']="$(koopa_app_prefix 'libpng')"
    dict['libtiff']="$(koopa_app_prefix 'libtiff')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['shared_ext']="$(koopa_shared_ext)"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['zlib']="$(koopa_app_prefix 'zlib')"
    # Following the definitions from conda-forge here.
    cmake['png_include_dir']="${dict['libpng']}/include"
    cmake['png_library']="${dict['libpng']}/lib/libpng.${dict['shared_ext']}"
    cmake['tiff_include_dir']="${dict['libtiff']}/include"
    cmake['tiff_library']="${dict['libtiff']}/lib/libtiff.${dict['shared_ext']}"
    cmake['zlib_include_dir']="${dict['zlib']}/include"
    cmake['zlib_library']="${dict['zlib']}/lib/libz.${dict['shared_ext']}"
    cmake_args=(
        # Build options --------------------------------------------------------
        '-DBUILD_DOC=OFF'
        '-DBUILD_SHARED_LIBS=ON'
        '-DBUILD_STATIC_LIBS=OFF'
        # Dependency paths -----------------------------------------------------
        "-DPNG_LIBRARY=${cmake['png_library']}"
        "-DPNG_INCLUDE_DIR=${cmake['png_include_dir']}"
        "-DTIFF_INCLUDE_DIR=${cmake['tiff_include_dir']}"
        "-DTIFF_LIBRARY=${cmake['tiff_library']}"
        "-DZLIB_INCLUDE_DIR=${cmake['zlib_include_dir']}"
        "-DZLIB_LIBRARY=${cmake['zlib_library']}"
    )
    dict['url']="https://github.com/uclouvain/openjpeg/archive/\
v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}
