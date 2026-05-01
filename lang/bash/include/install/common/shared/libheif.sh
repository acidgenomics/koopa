#!/usr/bin/env bash

main() {
    # """
    # Install libheif.
    # @note Updated 2023-12-17.
    #
    # @seealso
    # - https://formulae.brew.sh/formula/libheif
    # - https://github.com/ImageMagick/ImageMagick/issues/1140
    # """
    local -A dict
    local -a deps
    deps+=(
        'zlib'
        'libde265'
        'libjpeg-turbo'
        'libpng'
    )
    _koopa_activate_app --build-only 'pkg-config'
    _koopa_activate_app "${deps[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/strukturag/libheif/releases/download/\
v${dict['version']}/libheif-${dict['version']}.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_cmake_build --prefix="${dict['prefix']}"
    return 0
}
