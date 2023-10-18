#!/usr/bin/env bash

# FIXME This requires libudev to be installed.
# -- UDEV_INCLUDE_DIRS:
# -- UDEV_LIBRARIES:
# -- UDEV_LIBRARY_DIRS:

main() {
    # """
    # Install libfido2.
    # @note Updated 2023-05-26.
    #
    # @seealso
    # - https://formulae.brew.sh/formula/libfido2
    # """
    local -A dict
    local -a cmake_args
    koopa_activate_app --build-only 'pkg-config'
    koopa_activate_app 'libcbor' 'openssl3' 'zlib'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/Yubico/libfido2/archive/\
${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    cmake_args=(
        # Build options --------------------------------------------------------
        '-DBUILD_STATIC_LIBS=OFF'
    )
    koopa_cmake_build \
        --include-dir='include' \
        --lib-dir='lib' \
        --prefix="${dict['prefix']}" \
        "${cmake_args[@]}"
    return 0
}
