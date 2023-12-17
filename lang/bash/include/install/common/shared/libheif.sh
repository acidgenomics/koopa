#!/usr/bin/env bash

main() {
    # """
    # Install libheif.
    # @note Updated 2023-12-17.
    #
    # @seealso
    # - https://formulae.brew.sh/formula/libheif
    # """
    local -A dict
    koopa_activate_app --build-only 'pkg-config'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/strukturag/libheif/releases/download/\
v${dict['version']}/libheif-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_cmake_build --prefix="${dict['prefix']}"
    return 0
}
