#!/usr/bin/env bash

main() {
    # """
    # Install zstd.
    # @note Updated 2023-03-30.
    #
    # @seealso
    # - https://facebook.github.io/zstd/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/zstd.rb
    # """
    local cmake_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'pkg-config'
    koopa_activate_app 'lz4' 'zlib'
    declare -A dict=(
        ['lz4']="$(koopa_app_prefix 'lz4')"
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['shared_ext']="$(koopa_shared_ext)"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
        ['zlib']="$(koopa_app_prefix 'zlib')"
    )
    cmake_args=(
        # CMake options --------------------------------------------------------
        '-DCMAKE_CXX_STANDARD=11'
        # Build options --------------------------------------------------------
        '-DZSTD_BUILD_CONTRIB=ON'
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
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src/build/cmake'
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}
