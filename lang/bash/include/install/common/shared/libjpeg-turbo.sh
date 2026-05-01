#!/usr/bin/env bash

# NOTE Add support for NASM compiler, to improve performance.
# SIMD extensions disabled: could not find NASM compiler.

main() {
    # """
    # Install libjpeg-turbo.
    # @note Updated 2024-01-24.
    #
    # @seealso
    # - https://libjpeg-turbo.org/
    # - https://github.com/libjpeg-turbo/libjpeg-turbo/blob/main/BUILDING.md
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     jpeg-turbo.rb
    # """
    local -A dict
    local -a cmake_args
    _koopa_activate_app --build-only 'pkg-config'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    cmake_args=(
        '-DENABLE_STATIC=OFF'
        '-DWITH_JPEG8=ON'
    )
    dict['url']="https://github.com/libjpeg-turbo/libjpeg-turbo/releases/\
download/${dict['version']}/libjpeg-turbo-${dict['version']}.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_cmake_build \
        --prefix="${dict['prefix']}" \
        "${cmake_args[@]}"
    return 0
}
