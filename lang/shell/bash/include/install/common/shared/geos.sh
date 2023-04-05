#!/usr/bin/env bash

main() {
    # """
    # Install GEOS.
    # @note Updated 2023-03-31.
    #
    # @seealso
    # - https://github.com/libgeos/geos/blob/main/INSTALL.md
    # """
    local cmake_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'pkg-config'
    local -A dict=(
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    cmake_args=(
        '-DBUILD_SHARED_LIBS=ON'
        '-DGEOS_ENABLE_TESTS=OFF'
    )
    dict['url']="https://github.com/libgeos/geos/archive/\
${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}
