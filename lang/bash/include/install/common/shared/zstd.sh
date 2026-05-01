#!/usr/bin/env bash

# NOTE Rework using a cmake dict.

main() {
    # """
    # Install zstd.
    # @note Updated 2023-04-10.
    #
    # @seealso
    # - https://facebook.github.io/zstd/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/zstd.rb
    # """
    local -A dict
    local -a cmake_args
    _koopa_activate_app --build-only 'pkg-config'
    _koopa_activate_app 'lz4' 'zlib'
    dict['lz4']="$(_koopa_app_prefix 'lz4')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['shared_ext']="$(_koopa_shared_ext)"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['zlib']="$(_koopa_app_prefix 'zlib')"
    cmake_args=(
        # CMake options --------------------------------------------------------
        '-DCMAKE_CXX_STANDARD=11'
        # Build options --------------------------------------------------------
        '-DZSTD_BUILD_CONTRIB=ON'
        '-DZSTD_BUILD_STATIC=OFF'
        '-DZSTD_LEGACY_SUPPORT=ON'
        '-DZSTD_LZ4_SUPPORT=ON'
        '-DZSTD_LZMA_SUPPORT=OFF'
        '-DZSTD_PROGRAMS_LINK_SHARED=ON'
        '-DZSTD_ZLIB_SUPPORT=ON'
        # Dependency paths -----------------------------------------------------
        "-DLIBLZ4_INCLUDE_DIR=${dict['lz4']}/include"
        "-DLIBLZ4_LIBRARY=${dict['lz4']}/lib/liblz4.${dict['shared_ext']}"
        "-DZLIB_INCLUDE_DIR=${dict['zlib']}/include"
        "-DZLIB_LIBRARY=${dict['zlib']}/lib/libz.${dict['shared_ext']}"
    )
    dict['url']="https://github.com/facebook/zstd/archive/\
v${dict['version']}.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src/build/cmake'
    _koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}
