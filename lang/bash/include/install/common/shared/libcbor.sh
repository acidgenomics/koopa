#!/usr/bin/env bash

main() {
    # """
    # Install libcbor.
    # @note Updated 2023-05-26.
    #
    # @seealso
    # - https://formulae.brew.sh/formula/libcbor
    # """
    local -A dict
    local -a cmake_args
    koopa_activate_app --build-only 'pkg-config'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/PJK/libcbor/archive/v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    cmake_args=(
        # Build options --------------------------------------------------------
        '-DBUILD_SHARED_LIBS=ON'
        '-DWITH_EXAMPLES=OFF'
    )
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}
