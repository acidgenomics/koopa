#!/usr/bin/env bash

main() {
    # """
    # Install libfido2.
    # @note Updated 2023-10-18.
    #
    # @seealso
    # - https://formulae.brew.sh/formula/libfido2
    # """
    local -A dict
    local -a cmake_args
    _koopa_activate_app --build-only 'pkg-config'
    _koopa_activate_app 'libcbor' 'openssl' 'zlib'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/Yubico/libfido2/archive/\
${dict['version']}.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    cmake_args+=(
        # Build options --------------------------------------------------------
        '-DBUILD_STATIC_LIBS=OFF'
    )
    _koopa_cmake_build \
        --include-dir='include' \
        --lib-dir='lib' \
        --prefix="${dict['prefix']}" \
        "${cmake_args[@]}"
    return 0
}
