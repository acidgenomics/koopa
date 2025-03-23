#!/usr/bin/env bash

main() {
    # """
    # Install mimalloc.
    # @note Updated 2023-10-19.
    #
    # @seealso
    # - https://github.com/microsoft/mimalloc/
    # - https://formulae.brew.sh/formula/mimalloc
    # """
    local -A dict
    local -a cmake_args
    koopa_activate_app --build-only 'pkg-config'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    cmake_args=('-DMI_INSTALL_TOPLEVEL=ON')
    dict['url']="https://github.com/microsoft/mimalloc/archive/refs/tags/\
v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}
