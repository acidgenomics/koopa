#!/usr/bin/env bash

main() {
    # """
    # Install woff2.
    # @note Updated 2023-05-15.
    #
    # @seealso
    # - https://facebook.github.io/zstd/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/zstd.rb
    # """
    local -A dict
    local -a cmake_args
    koopa_activate_app --build-only 'brotli' 'pkg-config'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    cmake_args=(
        # CMake options --------------------------------------------------------
        # > '-DCMAKE_MACOSX_RPATH=ON'
        "-DCMAKE_INSTALL_NAME_DIR=${dict['prefix']}/lib"
        '-DCMAKE_BUILD_WITH_INSTALL_NAME_DIR=ON'
        # Build options --------------------------------------------------------
        '-DBUILD_SHARED_LIBS=ON'
    )
    dict['url']="https://github.com/google/woff2/archive/\
v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_mkdir \
        "${dict['prefix']}/include" \
        "${dict['prefix']}/lib"
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    koopa_cp \
        --target-directory="${dict['prefix']}/bin" \
        'builddir'*/'woff2_'*
    return 0
}
